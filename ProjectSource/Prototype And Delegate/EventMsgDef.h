/*
 * EventMsgDef.h
 *	Define Shmadia Event Message Type and Context
 *  Created on: 2016-08-05
 *  Author: nuvoton
 *
 */

//Change Log:
//
//  2016-08-05 - Create login message
//

#ifndef __EVENT_MSG_DEF_H__
#define __EVENT_MSG_DEF_H__

#include <inttypes.h>

/////////////////////////////////////////////////////////////////////////////////
/////////////////// Message Type Define//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

// BOOLEAN MACRO
#if defined(FALSE)	&&	FALSE != 0
	#error FALSE is not defined as 0.
#else
	#undef FALSE
#endif

#if defined(TRUE)	&&	TRUE != 1
	#error TRUE is not defined as 1.
#else
	#undef TRUE
#endif

/* Type definition */
//typedef enum {
//	FALSE		= 0,
//	TRUE		= 1,
//} BOOL;
/*__BOOL MACRO */


// Event Message Type
typedef enum {
	//Device and Clinet message
	eEVENTMSG_LOGIN					= 0x0100,		//Device/Client login message
	eEVENTMSG_LOGIN_RESP			= 0x0101,		//Device/Client login response message 

	//Device message
	eEVENTMSG_EVENT_NOTIFY			= 0x0200,		//Device event notify message
	eEVENTMSG_EVENT_NOTIFY_RESP		= 0x0201,		//Device event notify response message

	//Client message	start from 0x0300

}E_EVENTMSG_TYPE;

/////////////////////////////////////////////////////////////////////////////////
/////////////////// Type ENUM Define ////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

// Event return code
typedef enum {
	eEVENTMSG_RET_SUCCESS			= 0,
	eEVENTMSG_RET_UUID_INVALID		= -1,
	eEVENTMSG_RET_ACCESS_LIMITED	= -2,
}E_EVENTMSG_RET_CODE;

typedef enum {
	eEVENTMSG_ROLE_DEVICE = 0,			//Ex: IP camera, Doorbell
	eEVENTMSG_ROLE_USER = 1,			//Ex: mobile phone
}E_EVENTMSG_ROLE;


typedef enum{
	eEVENT_MOTION_DET = 0,				//motion detect
	eEVENT_RING = 1,					//ringing
}E_EVENT_TYPE;

/////////////////////////////////////////////////////////////////////////////
///////////////////////// Message Header Define ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////

typedef struct{
	uint32_t eMsgType;				//E_EVENTMSG_TYPE
	uint32_t u32MsgLen;			//include message header length
}__attribute__ ((packed))S_EVENTMSG_HEADER; // length: 8bytes


/////////////////////////////////////////////////////////////////////////////
///////////////////////// Message Body Define ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////

#define DEVICE_UUID_LEN		(64)					// Device UUDI length
#define CM_REGID_LEN		(254)					// Google cloud message register ID length

// Login request message
typedef struct{
	S_EVENTMSG_HEADER sMsgHdr; //8 bytes
	char szUUID[DEVICE_UUID_LEN + 1]; //64+1 bytes
	uint32_t eRole;							//E_EVENTMSG_ROLE, 4 bytes
	char szCloudRegID[CM_REGID_LEN + 1];		// Used by client login request, 255 bytes
	uint32_t u32DevPrivateIP;					// Used by device. Device private IP address. 4 bytes
	uint32_t u32DevHTTPPort;					// Used by device. Device http service port. 4 bytes
	uint32_t u32DevRTSPPort;					// Used by device. Device rtsp service port. 4 bytes
}__attribute__ ((packed)) S_EVENTMSG_LOGIN_REQ; //total: 344 bytes

// Login response message
typedef struct {
	S_EVENTMSG_HEADER sMsgHdr;
	int32_t eResult;					// E_EVENTMSG_RET_CODE. eEVENTMSG_RET_SUCCESS: success; otherwise: failed.
	uint32_t bDevOnline;				// BOOL. Report to client. Device online or not.
	uint32_t u32DevPublicIP;			// Report to client. Device public IP address.
	uint32_t u32DevPrivateIP;			// Report to client. Device private IP address.
	uint32_t u32DevHTTPPort;			// Report to client. Device http service port.
	uint32_t u32DevRTSPPort;			// Report to client. Device rtsp service port.
}__attribute__ ((packed)) S_EVENTMSG_LOGIN_RESP;

// Event notify message
typedef struct {
	S_EVENTMSG_HEADER sMsgHdr;
	char szUUID[DEVICE_UUID_LEN + 1];	
	uint32_t eEventType;			// E_EVENT_TYPE. Event type
	uint32_t u32Reserved;
}__attribute__ ((packed)) S_EVENTMSG_EVENT_NOTIFY;

// Event notify response message
typedef struct {
	S_EVENTMSG_HEADER sMsgHdr;
	int32_t eResult;		// E_EVENTMSG_RET_CODE. eEVENTMSG_RET_SUCCESS: success; otherwise: failed.
}__attribute__ ((packed)) S_EVENTMSG_EVENT_NOTIFY_RESP;


#endif

