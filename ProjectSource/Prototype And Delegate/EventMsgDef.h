/*
 * EventMsgDef.h
 *	Define Shmadia Event Message Type and Context
 *  Created on: 2016-08-05
 *  Author: nuvoton
 *
 */

//Change Log:
//
//  2016-08-05 - Create login and event message
//	2016-12-15 - Create firmware message and added signature word at message header
//

#ifndef __EVENT_MSG_DEF_H__
#define __EVENT_MSG_DEF_H__

#include <inttypes.h>

/////////////////////////////////////////////////////////////////////////////////
/////////////////// Message Type Define//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

#define SIGNATURE_WORD		0x525566

// Event Message Type
typedef enum {
	//Device and Clinet message
	eEVENTMSG_LOGIN					= 0x0100,		//Device/Client login message
	eEVENTMSG_LOGIN_RESP			= 0x0101,		//Device/Client login response message 

	//Device message
	eEVENTMSG_EVENT_NOTIFY			= 0x0200,		//Device event notify message
	eEVENTMSG_EVENT_NOTIFY_RESP		= 0x0201,		//Device event notify response message

	//Client message	start from 0x0300
	eEVENTMSG_GET_FW_VER			= 0x0300,		//Client get firmware version number request
	eEVENTMSG_GET_FW_VER_RESP		= 0x0301,		//Client get firmware version number response 

	eEVENTMSG_FW_DOWNLOAD			= 0x0302,		//Client firmware download request
	eEVENTMSG_FW_DOWNLOAD_RESP		= 0x0303,		//Client firmware download response 
}E_EVENTMSG_TYPE;

/////////////////////////////////////////////////////////////////////////////////
/////////////////// Type ENUM Define ////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

// Event return code
typedef enum {
	eEVENTMSG_RET_SUCCESS			= 0,
	eEVENTMSG_RET_UUID_INVALID		= -1,
	eEVENTMSG_RET_ACCESS_LIMITED	= -2,
	eEVENTMSG_RET_FW_VER_UNKNOWN	= -3,
	eEVENTMSG_RET_FW_DOWNLOAD_FAIL	= -4,
}E_EVENTMSG_RET_CODE;

typedef enum {
	eEVENTMSG_ROLE_DEVICE = 0,			//Ex: IP camera, Doorbell
	eEVENTMSG_ROLE_USER = 1,			//Ex: mobile phone
}E_EVENTMSG_ROLE;


typedef enum{
	eEVENT_MOTION_DET = 0,				//motion detect
	eEVENT_RING = 1,					//ringing
	eEVENT_BATTERY_LOW = 2				//battery low
}E_EVENT_TYPE;

typedef enum{
	eFW_DOWNLOAD_TYPE_NATIVE,			//NuDoorbell
	eFW_DOWNLOAD_TYPE_WIFI,				//RAK439
	eFW_DOWNLOAD_TYPE_NANO,				//NANO
	eFW_DOWNLOAD_TYPE_CNT,	
}E_FW_DOWNLOAD_TYPE;

/////////////////////////////////////////////////////////////////////////////
///////////////////////// Message Header Define ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////

typedef struct{
#if defined (SIGNATURE_WORD)
	uint32_t u32SignWord;			//Signature word. SIGNATURE_WORD
#endif
	uint32_t eMsgType;				//E_EVENTMSG_TYPE
	uint32_t u32MsgLen;			//include message header length
}__attribute__ ((packed))S_EVENTMSG_HEADER;


/////////////////////////////////////////////////////////////////////////////
///////////////////////// Message Body Define ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////

#define DEVICE_UUID_LEN		(64)					// Device UUDI length
#define CM_REGID_LEN		(254)					// Google cloud message register ID length

// Login request message
typedef struct{
	S_EVENTMSG_HEADER sMsgHdr;
	char szUUID[DEVICE_UUID_LEN + 1];
	uint32_t eRole;							//E_EVENTMSG_ROLE
	char szCloudRegID[CM_REGID_LEN + 1];		// Used by client login request
	uint32_t u32DevPrivateIP;					// Used by device. Device private IP address.
	uint32_t u32DevHTTPPort;					// Used by device. Device http service port.
	uint32_t u32DevRTSPPort;					// Used by device. Device rtsp service port.
}__attribute__ ((packed)) S_EVENTMSG_LOGIN_REQ;

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
	uint32_t u32EventSeqNo;
}__attribute__ ((packed)) S_EVENTMSG_EVENT_NOTIFY;

// Event notify response message
typedef struct {
	S_EVENTMSG_HEADER sMsgHdr;
	int32_t eResult;		// E_EVENTMSG_RET_CODE. eEVENTMSG_RET_SUCCESS: success; otherwise: failed.
}__attribute__ ((packed)) S_EVENTMSG_EVENT_NOTIFY_RESP;

// Get firmware version number message
typedef struct {
	S_EVENTMSG_HEADER sMsgHdr;
	char szUUID[DEVICE_UUID_LEN + 1];	
	uint32_t eFirmwareType;			// E_FW_SECTION_TYPE. Firmware section type
}__attribute__ ((packed)) S_EVENTMSG_GET_FW_VER;

// Get firmware version number response message
typedef struct {
	S_EVENTMSG_HEADER sMsgHdr;
	int32_t eResult;		// E_EVENTMSG_RET_CODE. eEVENTMSG_RET_SUCCESS: success; otherwise: failed.
	uint32_t u32FWVer;
}__attribute__ ((packed)) S_EVENTMSG_GET_FW_VER_RESP;

// Firmware download message
typedef struct {
	S_EVENTMSG_HEADER sMsgHdr;
	char szUUID[DEVICE_UUID_LEN + 1];	
	uint32_t eFirmwareType;				// E_FW_DOWNLOAD_TYPE. Firmware download type
}__attribute__ ((packed)) S_EVENTMSG_FW_DOWNLOAD;

// Firmware download response message
typedef struct {
	S_EVENTMSG_HEADER sMsgHdr;
	int32_t eResult;						// E_EVENTMSG_RET_CODE. eEVENTMSG_RET_SUCCESS: success; otherwise: failed.
	uint32_t u32FWLen;
}__attribute__ ((packed)) S_EVENTMSG_FW_DOWNLOAD_RESP;

#endif

