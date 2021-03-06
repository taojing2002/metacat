/**
 *  '$RCSfile$'
 *  Copyright: 2004 Regents of the University of California and the
 *             National Center for Ecological Analysis and Synthesis
 *
 *   '$Author: sgarg $'
 *     '$Date: 2005-04-04 09:12:31 -0800 (Mon, 04 Apr 2005) $'
 * '$Revision: 2442 $'
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * Drop all of the objects in proper order
 */
set echo off

DROP SEQUENCE xml_nodes_id_seq;
DROP SEQUENCE xml_revisions_id_seq;
DROP SEQUENCE xml_catalog_id_seq;
DROP SEQUENCE xml_relation_id_seq;
DROP SEQUENCE xml_replication_id_seq;
DROP SEQUENCE xml_documents_id_seq;
DROP SEQUENCE accession_number_id_seq;
DROP SEQUENCE access_log_id_seq;
DROP SEQUENCE xml_returnfield_id_seq;
DROP SEQUENCE xml_queryresult_id_seq;

/* Drop triggers are not necessary */
DROP TRIGGER xml_nodes_before_insert;
DROP TRIGGER xml_revisions_before_insert;
DROP TRIGGER xml_catalog_before_insert;
DROP TRIGGER xml_relation_before_insert;
DROP TRIGGER xml_replication_before_insert;
DROP TRIGGER accession_number_before_insert;
DROP TRIGGER access_log_before_insert;
DROP TRIGGER xml_returnfield_before_insert;
DROP TRIGGER xml_queryresult_before_insert;


DROP TABLE xml_index;
DROP TABLE xml_access;
DROP TABLE xml_accesssubtree;
DROP TABLE xml_revisions;
DROP TABLE xml_relation;
DROP TABLE xml_documents;
DROP TABLE xml_nodes;
DROP TABLE xml_replication;
DROP TABLE xml_catalog;
DROP TABLE accession_number;
DROP TABLE access_log;
DROP TABLE harvest_site_schedule;
DROP TABLE harvest_detail_log;
DROP TABLE harvest_log;
DROP TABLE xml_queryresult;
DROP TABLE xml_returnfield;

/*
 *Replication -- table to store servers that metacat is replicated to
 */
CREATE TABLE xml_replication (
  serverid      NUMBER(20),
  server        VARCHAR2(512),
  last_checked  DATE,
  replicate     NUMBER(1),
  datareplicate NUMBER(1),
  hub NUMBER(1),
  CONSTRAINT xml_replication_pk PRIMARY KEY (serverid)
);

CREATE SEQUENCE xml_replication_id_seq;
CREATE TRIGGER xml_replication_before_insert
BEFORE INSERT ON xml_replication FOR EACH ROW
BEGIN
  SELECT xml_replication_id_seq.nextval
    INTO :new.serverid
    FROM dual;
END;
/

INSERT INTO xml_replication (server, replicate, datareplicate, hub)
 VALUES ('localhost', '0', '0', '0');

/*
 * Nodes -- table to store XML Nodes (both elements and attributes)
 */
CREATE SEQUENCE xml_nodes_id_seq;
CREATE TABLE xml_nodes (
	nodeid		NUMBER(20),	-- the unique node id (pk)
	nodeindex	NUMBER(10),	-- order of nodes within parent
	nodetype	VARCHAR2(20),	-- type (DOCUMENT, COMMENT, PI,
					-- ELEMENT, ATTRIBUTE, TEXT)
	nodename	VARCHAR2(250),	-- the name of an element or attribute
	nodeprefix	VARCHAR2(50),	-- the namespace prefix of an element
                                        -- or attribute
	nodedata	VARCHAR2(4000), -- the data for this node (e.g.,
					-- for TEXT it is the content)
	parentnodeid	NUMBER(20),	-- index of the parent of this node
	rootnodeid	NUMBER(20),	-- index of the root node of this tree
	docid		VARCHAR2(250),	-- index to the document id
	date_created	DATE,
	date_updated	DATE,
	nodedatanumerical NUMBER,       -- the data for this node if
					-- it is a number
   CONSTRAINT xml_nodes_pk PRIMARY KEY (nodeid),
   CONSTRAINT xml_nodes_root_fk
		FOREIGN KEY (rootnodeid) REFERENCES xml_nodes,
   CONSTRAINT xml_nodes_parent_fk
		FOREIGN KEY (parentnodeid) REFERENCES xml_nodes
);
CREATE TRIGGER xml_nodes_before_insert
BEFORE INSERT ON xml_nodes FOR EACH ROW
BEGIN
  SELECT xml_nodes_id_seq.nextval
    INTO :new.nodeid
    FROM dual;
END;
/

/*
 * Indexes of rootnodeid, parentnodeid, and nodename in xml_nodes
 */
CREATE INDEX xml_nodes_idx1 ON xml_nodes (rootnodeid);
CREATE INDEX xml_nodes_idx2 ON xml_nodes (parentnodeid);
CREATE INDEX xml_nodes_idx3 ON xml_nodes (nodename);

/*
 * XML Catalog -- table to store all external sources for XML documents
 */
CREATE TABLE xml_catalog (
	catalog_id	NUMBER(20),	-- the id for this catalog entry
	entry_type	VARCHAR2(500),	-- the type of this catalog entry
					-- (e.g., DTD, XSD, XSL)
	source_doctype	VARCHAR2(500),	-- the source public_id for transforms
	target_doctype	VARCHAR2(500),	-- the target public_id for transforms
	public_id	VARCHAR2(500),	-- the unique id for this type
	system_id	VARCHAR2(1000),	-- the local location of the object
   CONSTRAINT xml_catalog_pk PRIMARY KEY (catalog_id),
   CONSTRAINT xml_catalog_uk UNIQUE
		(entry_type, source_doctype, target_doctype, public_id)
);

CREATE SEQUENCE xml_catalog_id_seq;

CREATE TRIGGER xml_catalog_before_insert
BEFORE INSERT ON xml_catalog FOR EACH ROW
BEGIN
  SELECT xml_catalog_id_seq.nextval
    INTO :new.catalog_id
    FROM dual;
END;
/

/*
 * Documents -- table to store XML documents
 */
CREATE TABLE xml_documents (
	docid		VARCHAR2(250),	-- the document id #
	rootnodeid	NUMBER(20),	-- reference to root node of the DOM
	docname		VARCHAR2(100),	-- usually the root element name
	doctype		VARCHAR2(100),	-- public id indicating document type
	user_owner	VARCHAR2(100),	-- the user owned the document
	user_updated	VARCHAR2(100),	-- the user updated the document
	server_location NUMBER(20),	-- the server on which this document
                                        -- originates
	rev 		NUMBER(10) DEFAULT 1,--the revision number of the docume
	date_created	DATE,
	date_updated	DATE,
	public_access	NUMBER(1),	-- flag for public access
        catalog_id      NUMBER(20),	-- reference to xml_catalog
   CONSTRAINT xml_documents_pk PRIMARY KEY (docid),
   CONSTRAINT xml_documents_rep_fk
    		FOREIGN KEY (server_location) REFERENCES xml_replication,
   CONSTRAINT xml_documents_root_fk
		FOREIGN KEY (rootnodeid) REFERENCES xml_nodes,
   CONSTRAINT xml_documents_catalog_fk
		FOREIGN KEY (catalog_id) REFERENCES xml_catalog
);

/*
 * Index of <docid,doctype> in xml_document
 */
CREATE INDEX xml_documents_idx1 ON xml_documents (docid, doctype);

/*
 * Revised Documents -- table to store XML documents saved after an UPDATE
 *                    or DELETE
 */
CREATE TABLE xml_revisions (
	revisionid	NUMBER(20),	-- the revision number we are saving
	docid		VARCHAR2(250),	-- the document id #
	rootnodeid	NUMBER(20),	-- reference to root node of the DOM
	docname		VARCHAR2(100),	-- usually the root element name
	doctype		VARCHAR2(100),	-- public id indicating document type
	user_owner	VARCHAR2(100),
	user_updated	VARCHAR2(100),
	server_location NUMBER(20),
	rev		NUMBER(10),
	date_created	DATE,
	date_updated	DATE,
	public_access	NUMBER(1),	-- flag for public access
        catalog_id      NUMBER(20),	-- reference to xml_catalog
   CONSTRAINT xml_revisions_pk PRIMARY KEY (revisionid),
   CONSTRAINT xml_revisions_rep_fk
		FOREIGN KEY (server_location) REFERENCES xml_replication,
   CONSTRAINT xml_revisions_root_fk
		FOREIGN KEY (rootnodeid) REFERENCES xml_nodes,
   CONSTRAINT xml_revisions_catalog_fk
		FOREIGN KEY (catalog_id) REFERENCES xml_catalog
);

CREATE SEQUENCE xml_revisions_id_seq;

CREATE TRIGGER xml_revisions_before_insert
BEFORE INSERT ON xml_revisions FOR EACH ROW
BEGIN
  SELECT xml_revisions_id_seq.nextval
    INTO :new.revisionid
    FROM dual;
END;
/

/*
 * ACL -- table to store ACL for XML documents by principals
 */
CREATE TABLE xml_access (
	docid		VARCHAR2(250),	-- the document id #
	accessfileid	VARCHAR2(250),	-- the document id # for the access file
	principal_name	VARCHAR2(100),	-- name of user, group, etc.
	permission	NUMBER(1),	-- "read", "write", "all"
	perm_type	VARCHAR2(32),	-- "allowed" or "denied"
	perm_order	VARCHAR2(32),	-- "allow first" or "deny first"
	begin_time	DATE,		-- the time that permission begins
	end_time	DATE,		-- the time that permission ends
	ticket_count	NUMBER(5),	-- ticket counter for that permission
  subtreeid VARCHAR2(32), -- sub tree id
  startnodeid NUMBER(20), -- start node for sub tree
  endnodeid NUMBER(20),    -- end node for sub tree
   CONSTRAINT xml_access_ck CHECK (begin_time < end_time),
   CONSTRAINT xml_access_accessfileid_fk
		FOREIGN KEY (accessfileid) REFERENCES xml_documents
);

/*
 * Index of Nodes -- table to store precomputed paths through tree for
 * quick searching in structured searches
 */
CREATE TABLE xml_index (
	nodeid		NUMBER(20),	-- the unique node id
	path		VARCHAR2(1000),	-- precomputed path through tree
	docid		VARCHAR2(250),	-- index to the document id
	doctype		VARCHAR2(100),	-- public id indicating document type
        parentnodeid    NUMBER(20),     -- id of the parent of the node
					-- represented by this row
   CONSTRAINT xml_index_pk PRIMARY KEY (nodeid,path),
   CONSTRAINT xml_index_nodeid_fk FOREIGN KEY (nodeid) REFERENCES xml_nodes,
   CONSTRAINT xml_index_docid_fk
		FOREIGN KEY (docid) REFERENCES xml_documents
);

/*
 * Index of the paths in xml_index
 */
CREATE INDEX xml_index_idx1 ON xml_index (path);

CREATE TABLE xml_relation (
	relationid    NUMBER(20) PRIMARY KEY, -- unique id
	docid         VARCHAR2(250),          -- the docid of the package file
	                                      -- that this relation came from
        packagetype   VARCHAR2(250),          -- the type of the package
	subject       VARCHAR2(512) NOT NULL, -- the subject of the relation
	subdoctype    VARCHAR2(128),          -- the doctype of the subject
	relationship  VARCHAR2(128)  NOT NULL,-- the relationship type
	object        VARCHAR2(512) NOT NULL, -- the object of the relation
	objdoctype    VARCHAR2(128),          -- the doctype of the object
	CONSTRAINT xml_relation_uk UNIQUE (docid, subject, relationship, object),
	CONSTRAINT xml_relation_docid_fk
		FOREIGN KEY (docid) REFERENCES xml_documents
  );

CREATE SEQUENCE xml_relation_id_seq;

CREATE TRIGGER xml_relation_before_insert
BEFORE INSERT ON xml_relation FOR EACH ROW
BEGIN
  SELECT xml_relation_id_seq.nextval
    INTO :new.relationid
    FROM dual;
END;
/

/*
 * Table used as Unique ID generator for the uniqueid part of Accession#
 */
CREATE SEQUENCE accession_number_id_seq;
CREATE TABLE accession_number (
	uniqueid	NUMBER(20) PRIMARY KEY,
	site_code	VARCHAR2(100),
	date_created	DATE
);
CREATE TRIGGER accession_number_before_insert
BEFORE INSERT ON accession_number FOR EACH ROW
BEGIN
  SELECT accession_number_id_seq.nextval
    INTO :new.uniqueid
    FROM dual;
END;
/

/*
 * accesssubtree -- table to store access subtree info
 */
CREATE TABLE xml_accesssubtree (
	docid		VARCHAR2(250),	-- the document id #
  rev 		NUMBER(10) DEFAULT 1, --the revision number of the docume
  controllevel VARCHAR2(50), -- the level it control -- document or subtree
  subtreeid VARCHAR2(250), -- the subtree id
	startnodeid	NUMBER(20),	-- the start node id of access subtree
  endnodeid NUMBER(20), -- the end node if of access subtree
  CONSTRAINT xml_accesssubtree_docid_fk
		FOREIGN KEY (docid) REFERENCES xml_documents
);

/*
 * Returnfields -- table to store combinations of returnfields requested
 *		   and the number of times this table is accessed
 */
CREATE TABLE xml_returnfield (
        returnfield_id     NUMBER(20),     -- the id for this returnfield entry
        returnfield_string VARCHAR2(2000), -- the returnfield string
        usage_count        NUMBER(20),     -- the number of times this string
                                           -- has been requested
        CONSTRAINT xml_returnfield_pk PRIMARY KEY (returnfield_id)
);
CREATE INDEX xml_returnfield_idx1 ON xml_returnfield(returnfield_string);

CREATE SEQUENCE xml_returnfield_id_seq;

CREATE TRIGGER xml_returnfield_before_insert
BEFORE INSERT ON xml_returnfield FOR EACH ROW
BEGIN
  SELECT xml_returnfield_id_seq.nextval
    INTO :new.returnfield_id
    FROM dual;
END;
/

/*
 * Queryresults -- table to store queryresults for a given docid
 * and returnfield_id
 */
CREATE TABLE xml_queryresult(
  queryresult_id       NUMBER(20),     -- id for this entry
  returnfield_id       NUMBER(20),     -- id for the returnfield corresponding to this entry
  docid                VARCHAR2(250),  -- docid of the document
  queryresult_string   VARCHAR2(4000), -- resultant text generated for this docid and given
  				       -- returnfield
  CONSTRAINT xml_queryresult_pk PRIMARY KEY (queryresult_id),
  CONSTRAINT xml_queryresult_searchid_fk
               FOREIGN KEY (returnfield_id) REFERENCES xml_returnfield
);

CREATE INDEX xml_queryresult_idx1 ON xml_queryresult (returnfield_id, docid);

CREATE SEQUENCE xml_queryresult_id_seq;

CREATE TRIGGER xml_queryresult_before_insert
BEFORE INSERT ON xml_queryresult FOR EACH ROW
BEGIN
 SELECT xml_queryresult_id_seq.nextval
   INTO :new.queryresult_id
   FROM dual;
END;
/

/*
 * Logging -- table to store metadata and data access log
 */
CREATE TABLE access_log (
  entryid       NUMBER(20),     -- the identifier for the log event
  ip_address    VARCHAR2(512),  -- the ip address inititiating the event
  principal     VARCHAR2(512),  -- the user initiiating the event
  docid         VARCHAR2(250),	-- the document id #
  event         VARCHAR2(512),  -- the code symbolizing the event type
  date_logged   DATE,           -- the datetime on which the event occurred
  CONSTRAINT access_log_pk PRIMARY KEY (entryid)
);

CREATE SEQUENCE access_log_id_seq;
CREATE TRIGGER access_log_before_insert
BEFORE INSERT ON access_log FOR EACH ROW
BEGIN
  SELECT access_log_id_seq.nextval
    INTO :new.entryid
    FROM dual;
END;
/

/*
 * harvest_site_schedule -- table to store harvest sites and schedule info
 */
CREATE TABLE harvest_site_schedule (
  site_schedule_id NUMBER,         -- unique id
  documentlisturl  VARCHAR2(255),  -- URL of the site harvest document list
  ldapdn           VARCHAR2(255),  -- LDAP distinguished name for site account
  datenextharvest  DATE,           -- scheduled date of next harvest
  datelastharvest  DATE,           -- recorded date of last harvest
  updatefrequency  NUMBER,         -- the harvest update frequency
  unit             VARCHAR2(50),   -- update unit -- days weeks or months
  contact_email    VARCHAR2(50),   -- email address of the site contact person
  ldappwd          VARCHAR2(20),   -- LDAP password for site account
  CONSTRAINT harvest_site_schedule_pk PRIMARY KEY (site_schedule_id)
);

/*
 * harvest_log -- table to log entries for harvest operations
 */
CREATE TABLE harvest_log (
  harvest_log_id         NUMBER,         -- unique id
  harvest_date           DATE,           -- date of the current harvest
  status                 NUMBER,         -- non-zero indicates an error status
  message                VARCHAR2(1000), -- text message for this log entry
  harvest_operation_code VARCHAR2(30),   -- the type of harvest operation
  site_schedule_id       NUMBER,         -- site schedule id, or 0 if no site
  CONSTRAINT harvest_log_pk PRIMARY KEY (harvest_log_id)
);

/*
 * harvest_detail_log -- table to log detailed info about documents that
 *                       generated errors during the harvest
 */
CREATE TABLE harvest_detail_log (
  detail_log_id          NUMBER,         -- unique id
  harvest_log_id         NUMBER,         -- ponter to the related log entry
  scope                  VARCHAR2(50),   -- document scope
  identifier             NUMBER,         -- document identifier
  revision               NUMBER,         -- document revision
  document_url           VARCHAR2(255),  -- document URL
  error_message          VARCHAR2(1000), -- text error message
  document_type          VARCHAR2(100),  -- document type
  CONSTRAINT harvest_detail_log_pk PRIMARY KEY (detail_log_id),
  CONSTRAINT harvest_detail_log_fk
        FOREIGN KEY (harvest_log_id) REFERENCES harvest_log
);

