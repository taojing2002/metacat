/**
 *  '$RCSfile$'
 *  Copyright: 2000-2011 Regents of the University of California and the
 *              National Center for Ecological Analysis and Synthesis
 *
 *   '$Author$'
 *     '$Date$'
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

package edu.ucsb.nceas.metacat.dataone.v1;

import java.io.InputStream;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.dataone.service.exceptions.IdentifierNotUnique;
import org.dataone.service.exceptions.InsufficientResources;
import org.dataone.service.exceptions.InvalidRequest;
import org.dataone.service.exceptions.InvalidSystemMetadata;
import org.dataone.service.exceptions.InvalidToken;
import org.dataone.service.exceptions.NotAuthorized;
import org.dataone.service.exceptions.NotFound;
import org.dataone.service.exceptions.NotImplemented;
import org.dataone.service.exceptions.ServiceFailure;
import org.dataone.service.exceptions.SynchronizationFailed;
import org.dataone.service.exceptions.UnsupportedType;
import org.dataone.service.mn.tier1.v1.MNCore;
import org.dataone.service.mn.tier1.v1.MNRead;
import org.dataone.service.mn.tier2.v1.MNAuthorization;
import org.dataone.service.mn.tier3.v1.MNStorage;
import org.dataone.service.mn.tier4.v1.MNReplication;
import org.dataone.service.mn.v1.MNQuery;
import org.dataone.service.types.v1.Checksum;
import org.dataone.service.types.v1.DescribeResponse;
import org.dataone.service.types.v1.Event;
import org.dataone.service.types.v1.Identifier;
import org.dataone.service.types.v1.Log;
import org.dataone.service.types.v1.Node;
import org.dataone.service.types.v1.NodeReference;
import org.dataone.service.types.v1.ObjectFormatIdentifier;
import org.dataone.service.types.v1.ObjectList;
import org.dataone.service.types.v1.Permission;
import org.dataone.service.types.v1.Session;
import org.dataone.service.types.v1.SystemMetadata;
import org.dataone.service.types.v1_1.QueryEngineDescription;
import org.dataone.service.types.v1_1.QueryEngineList;
import org.dataone.service.util.TypeMarshaller;

/**
 * Represents Metacat's implementation of the DataONE Member Node 
 * service API, v1. Methods typically pass through to the current 
 * version implementation performing type conversion as needed.
 * 
 */
public class MNodeService 
    implements MNAuthorization, MNCore, MNRead, MNReplication, MNStorage, MNQuery {

	/**
	 * current version implementation
	 */
	edu.ucsb.nceas.metacat.dataone.MNodeService impl = null;
	
	/* the logger instance */
    private Logger logMetacat = null;

    /**
     * Singleton accessor to get an instance of MNodeService.
     * 
     * @return instance - the instance of MNodeService
     */
    public static MNodeService getInstance(HttpServletRequest request) {
        return new MNodeService(request);
    }

    /**
     * Constructor, private for singleton access
     */
    private MNodeService(HttpServletRequest request) {
        logMetacat = Logger.getLogger(MNodeService.class);
        impl = edu.ucsb.nceas.metacat.dataone.MNodeService.getInstance(request);
    }
    
    public void setSession(Session session) {
    	impl.setSession(session);
    }
    
    public boolean isAdminAuthorized(Session session) throws ServiceFailure, InvalidToken, NotAuthorized, NotImplemented {
    	return impl.isAdminAuthorized(session);
    }

	@Override
	public QueryEngineDescription getQueryEngineDescription(String engine)
			throws InvalidToken, ServiceFailure, NotAuthorized, NotImplemented,
			NotFound {
		return impl.getQueryEngineDescription(null, engine);
	}

	@Override
	public QueryEngineList listQueryEngines() throws InvalidToken,
			ServiceFailure, NotAuthorized, NotImplemented {
		return impl.listQueryEngines(null);
	}

	@Override
	public InputStream query(String engine, String query) throws InvalidToken,
			ServiceFailure, NotAuthorized, InvalidRequest, NotImplemented,
			NotFound {
		return impl.query(null, engine, query);
	}

	@Override
	public Identifier archive(Identifier pid) throws InvalidToken,
			ServiceFailure, NotAuthorized, NotFound, NotImplemented {
		return impl.archive(null, pid);
	}

	@Override
	@Deprecated
	public Identifier archive(Session session, Identifier pid)
			throws InvalidToken, ServiceFailure, NotAuthorized, NotFound,
			NotImplemented {
		return impl.archive(session, pid);
	}

	@Override
	public Identifier create(Identifier pid, InputStream object,
			SystemMetadata sysmeta) throws IdentifierNotUnique,
			InsufficientResources, InvalidRequest, InvalidSystemMetadata,
			InvalidToken, NotAuthorized, NotImplemented, ServiceFailure,
			UnsupportedType {
		return this.create(null, pid, object, sysmeta);
	}

	@Override
	@Deprecated
	public Identifier create(Session session, Identifier pid, InputStream object,
			SystemMetadata sysmeta) throws IdentifierNotUnique,
			InsufficientResources, InvalidRequest, InvalidSystemMetadata,
			InvalidToken, NotAuthorized, NotImplemented, ServiceFailure,
			UnsupportedType {
		//convert sysmeta to newer version
		org.dataone.service.types.v2.SystemMetadata v2Sysmeta = null;
		try {
			v2Sysmeta = TypeMarshaller.convertTypeFromType(sysmeta, org.dataone.service.types.v2.SystemMetadata.class);
		} catch (Exception e) {
			// report as service failure
			ServiceFailure sf = new ServiceFailure("1190", e.getMessage());
			sf.initCause(e);
			throw sf;
		}
		
		return impl.create(session, pid, object, v2Sysmeta);
	}

	@Override
	public Identifier delete(Identifier pid) throws InvalidToken,
			ServiceFailure, NotAuthorized, NotFound, NotImplemented {
		return impl.delete(null, pid);
	}

	@Override
	@Deprecated
	public Identifier delete(Session session, Identifier pid)
			throws InvalidToken, ServiceFailure, NotAuthorized, NotFound,
			NotImplemented {
		return impl.delete(session, pid);
	}

	@Override
	public Identifier generateIdentifier(String scheme, String fragment)
			throws InvalidToken, ServiceFailure, NotAuthorized, NotImplemented,
			InvalidRequest {
		return impl.generateIdentifier(null, scheme, fragment);
	}

	@Override
	@Deprecated
	public Identifier generateIdentifier(Session session, String scheme, String fragment)
			throws InvalidToken, ServiceFailure, NotAuthorized, NotImplemented,
			InvalidRequest {
		return impl.generateIdentifier(session, scheme, fragment);
	}

	@Override
	public Identifier update(Identifier pid, InputStream object,
			Identifier newPid, SystemMetadata sysmeta) throws IdentifierNotUnique,
			InsufficientResources, InvalidRequest, InvalidSystemMetadata,
			InvalidToken, NotAuthorized, NotImplemented, ServiceFailure,
			UnsupportedType, NotFound {
		return this.update(null, pid, object, newPid, sysmeta);
	}

	@Override
	@Deprecated
	public Identifier update(Session session, Identifier pid, InputStream object,
			Identifier newPid, SystemMetadata sysmeta) throws IdentifierNotUnique,
			InsufficientResources, InvalidRequest, InvalidSystemMetadata,
			InvalidToken, NotAuthorized, NotImplemented, ServiceFailure,
			UnsupportedType, NotFound {
		//convert sysmeta to newer version
		org.dataone.service.types.v2.SystemMetadata v2Sysmeta = null;
		try {
			v2Sysmeta = TypeMarshaller.convertTypeFromType(sysmeta, org.dataone.service.types.v2.SystemMetadata.class);
		} catch (Exception e) {
			// report as service failure
			ServiceFailure sf = new ServiceFailure("1030", e.getMessage());
			sf.initCause(e);
			throw sf;
		}
		return impl.update(session, pid, object, newPid, v2Sysmeta);
	}

	@Override
	public boolean replicate(SystemMetadata sysmeta, NodeReference sourceNode)
			throws NotImplemented, ServiceFailure, NotAuthorized,
			InvalidRequest, InvalidToken, InsufficientResources,
			UnsupportedType {
		return this.replicate(null, sysmeta, sourceNode);
	}

	@Override
	@Deprecated
	public boolean replicate(Session session, SystemMetadata sysmeta,
			NodeReference sourceNode) throws NotImplemented, ServiceFailure,
			NotAuthorized, InvalidRequest, InvalidToken, InsufficientResources,
			UnsupportedType {
		//convert sysmeta to newer version
		org.dataone.service.types.v2.SystemMetadata v2Sysmeta = null;
		try {
			v2Sysmeta = TypeMarshaller.convertTypeFromType(sysmeta, org.dataone.service.types.v2.SystemMetadata.class);
		} catch (Exception e) {
			// report as service failure
			ServiceFailure sf = new ServiceFailure("1030", e.getMessage());
			sf.initCause(e);
			throw sf;
		}
		return impl.replicate(session, v2Sysmeta, sourceNode);
	}

	@Override
	public DescribeResponse describe(Identifier pid) throws InvalidToken,
			NotAuthorized, NotImplemented, ServiceFailure, NotFound {
		return impl.describe(null, pid);
	}

	@Override
	@Deprecated
	public DescribeResponse describe(Session session, Identifier pid)
			throws InvalidToken, NotAuthorized, NotImplemented, ServiceFailure,
			NotFound {
		return impl.describe(session, pid);
	}

	@Override
	public InputStream get(Identifier pid) throws InvalidToken, NotAuthorized,
			NotImplemented, ServiceFailure, NotFound, InsufficientResources {
		return impl.get(null, pid);
	}

	@Override
	@Deprecated
	public InputStream get(Session session, Identifier pid) throws InvalidToken,
			NotAuthorized, NotImplemented, ServiceFailure, NotFound,
			InsufficientResources {
		return impl.get(session, pid);
	}

	@Override
	public Checksum getChecksum(Identifier pid, String algorithm)
			throws InvalidRequest, InvalidToken, NotAuthorized, NotImplemented,
			ServiceFailure, NotFound {
		return impl.getChecksum(null, pid, algorithm);
	}

	@Override
	@Deprecated
	public Checksum getChecksum(Session session, Identifier pid, String algorithm)
			throws InvalidRequest, InvalidToken, NotAuthorized, NotImplemented,
			ServiceFailure, NotFound {
		return impl.getChecksum(session, pid, algorithm);
	}

	@Override
	public InputStream getReplica(Identifier pid) throws InvalidToken,
			NotAuthorized, NotImplemented, ServiceFailure, NotFound,
			InsufficientResources {
		return impl.getReplica(null, pid);
	}

	@Override
	@Deprecated
	public InputStream getReplica(Session session, Identifier pid)
			throws InvalidToken, NotAuthorized, NotImplemented, ServiceFailure,
			NotFound, InsufficientResources {
		return impl.get(session, pid);
	}

	@Override
	public SystemMetadata getSystemMetadata(Identifier pid)
			throws InvalidToken, NotAuthorized, NotImplemented, ServiceFailure,
			NotFound {
		
		return this.getSystemMetadata(null, pid);
		
	}

	@Override
	@Deprecated
	public SystemMetadata getSystemMetadata(Session session, Identifier pid)
			throws InvalidToken, NotAuthorized, NotImplemented, ServiceFailure,
			NotFound {
		org.dataone.service.types.v2.SystemMetadata sysMeta = impl.getSystemMetadata(session, pid);
		SystemMetadata retSysMeta = null;
		try {
			retSysMeta = TypeMarshaller.convertTypeFromType(sysMeta, SystemMetadata.class);
		} catch (Exception e) {
			// report as service failure
			ServiceFailure sf = new ServiceFailure("4801", e.getMessage());
			sf.initCause(e);
			throw sf;
		}
		return retSysMeta;
	}

	@Override
	public ObjectList listObjects(Date startTime, Date endTime,
			ObjectFormatIdentifier objectFormatId, Boolean replicaStatus, Integer start,
			Integer count) throws InvalidRequest, InvalidToken, NotAuthorized,
			NotImplemented, ServiceFailure {
		return this.listObjects(null, startTime, endTime, objectFormatId, replicaStatus, start, count);
	}

	@Override
	@Deprecated
	public ObjectList listObjects(Session session, Date startTime, Date endTime,
			ObjectFormatIdentifier objectFormatId, Boolean replicaStatus, Integer start,
			Integer count) throws InvalidRequest, InvalidToken, NotAuthorized,
			NotImplemented, ServiceFailure {
		return impl.listObjects(session, startTime, endTime, objectFormatId, null, replicaStatus, start, count);
	}

	@Override
	public boolean synchronizationFailed(SynchronizationFailed syncFailed)
			throws InvalidToken, NotAuthorized, NotImplemented, ServiceFailure {
		return impl.synchronizationFailed(null, syncFailed);
	}

	@Override
	@Deprecated
	public boolean synchronizationFailed(Session session,
			SynchronizationFailed syncFailed) throws InvalidToken, NotAuthorized,
			NotImplemented, ServiceFailure {
		return impl.synchronizationFailed(session, syncFailed);
	}

	@Override
	public Node getCapabilities() throws NotImplemented, ServiceFailure {
		org.dataone.service.types.v2.Node node = impl.getCapabilities();
		Node retNode = null;
		try {
			retNode = TypeMarshaller.convertTypeFromType(node, Node.class);
		} catch (Exception e) {
			// report as service failure
			ServiceFailure sf = new ServiceFailure("4801", e.getMessage());
			sf.initCause(e);
			throw sf;
		}
		return retNode;
	}

	@Override
	public Log getLogRecords(Date fromDate, Date toDate, Event event,
			String pidFilter, Integer start, Integer count) throws InvalidRequest, InvalidToken,
			NotAuthorized, NotImplemented, ServiceFailure {
		return this.getLogRecords(null, fromDate, toDate, event, pidFilter, start, count);
	}

	@Override
	@Deprecated
	public Log getLogRecords(Session session, Date fromDate, Date toDate, Event event,
			String pidFilter, Integer start, Integer count) throws InvalidRequest, InvalidToken,
			NotAuthorized, NotImplemented, ServiceFailure {
		org.dataone.service.types.v2.Log log = impl.getLogRecords(session, fromDate, toDate, event.xmlValue(), pidFilter, start, count);
		Log retLog = null;
		try {
			retLog = TypeMarshaller.convertTypeFromType(log, Log.class);
		} catch (Exception e) {
			// report as service failure
			ServiceFailure sf = new ServiceFailure("1490", e.getMessage());
			sf.initCause(e);
			throw sf;
		}
		return retLog;
	}

	@Override
	public Date ping() throws NotImplemented, ServiceFailure,
			InsufficientResources {
		return impl.ping();
	}

	@Override
	public boolean isAuthorized(Identifier pid, Permission permission)
			throws ServiceFailure, InvalidRequest, InvalidToken, NotFound,
			NotAuthorized, NotImplemented {
		return impl.isAuthorized(null, pid, permission);
	}

	@Override
	@Deprecated
	public boolean isAuthorized(Session session, Identifier pid, Permission permission)
			throws ServiceFailure, InvalidRequest, InvalidToken, NotFound,
			NotAuthorized, NotImplemented {
		return impl.isAuthorized(session, pid, permission);
	}

	@Override
	public boolean systemMetadataChanged(Identifier pid, long serialVersion, Date dateSysMetaLastModified)
			throws InvalidToken, ServiceFailure, NotAuthorized, NotImplemented,
			InvalidRequest {
		return impl.systemMetadataChanged(null, pid, serialVersion, dateSysMetaLastModified);

	}

	@Override
	@Deprecated
	public boolean systemMetadataChanged(Session session, Identifier pid,
			long serialVersion, Date dateSysMetaLastModified) throws InvalidToken, ServiceFailure,
			NotAuthorized, NotImplemented, InvalidRequest {
		return impl.systemMetadataChanged(session, pid, serialVersion, dateSysMetaLastModified);
	}
    
	// methods not defined in v1, but implemented in metacat pre-v2 release
	
	public Identifier publish(Session session, Identifier originalIdentifier) 
			throws InvalidToken, ServiceFailure, NotAuthorized, NotImplemented, InvalidRequest, NotFound, IdentifierNotUnique, UnsupportedType, InsufficientResources, InvalidSystemMetadata {
		return impl.publish(session, originalIdentifier);
		
	}
	
	public InputStream view(Session session, String format, Identifier pid)
			throws InvalidToken, ServiceFailure, NotAuthorized, InvalidRequest,
			NotImplemented, NotFound {
		
		return impl.view(session, format, pid);
	}
	
	public InputStream getPackage(Session session, ObjectFormatIdentifier formatId,
			Identifier pid) throws InvalidToken, ServiceFailure,
			NotAuthorized, InvalidRequest, NotImplemented, NotFound {
		return impl.getPackage(session, formatId, pid);
	}
	
    

   
}