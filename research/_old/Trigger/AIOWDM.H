#define WDG_ACTION_IGNORE 0
#define WDG_ACTION_DISABLE 1
#define WDG_ACTION_SOFT_RESTART 2
#define WDG_ACTION_MOSTLY_SOFT_RESTART 4
#define PCI_WDG_CSM_RATE 2.08333
#define P104_WDG_CSM_RATE 2.08333
#define ISA_WDG_CSM_RATE 0.894886

#ifdef __cplusplus
extern "C" {
#endif

__declspec(dllimport) signed long GetNumCards(void);
__declspec(dllimport) unsigned long QueryCardInfo(long CardNum, unsigned long *pDeviceID, unsigned long *pBase, unsigned long *pNameSize, unsigned char *pName);
__declspec(dllimport) unsigned long WaitForIRQ(long CardNum);
__declspec(dllimport) unsigned long AbortRequest(long CardNum);
__declspec(dllimport) unsigned long CloseCard(long CardNum);
__declspec(dllimport) unsigned long COSWaitForIRQ(long CardNum, unsigned long PPIs, void *pData);
__declspec(dllimport) unsigned long WDGInit(long CardNum);
__declspec(dllimport) unsigned long WDGHandleIRQ(long CardNum, unsigned long Action);
__declspec(dllimport) double WDGSetTimeout(long CardNum, double Milliseconds, double MHzClockRate);
__declspec(dllimport) double WDGSetResetDuration(long CardNum, double Milliseconds, double MHzClockRate);
__declspec(dllimport) unsigned long WDGPet(long CardNum);
__declspec(dllimport) double WDGReadTemp(long CardNum);
__declspec(dllimport) unsigned long WDGReadStatus(long CardNum);
__declspec(dllimport) unsigned long WDGStart(long CardNum);
__declspec(dllimport) unsigned long WDGStop(long CardNum);
__declspec(dllimport) unsigned long EmergencyReboot(void);


__declspec(dllimport) unsigned short InPortB         (              unsigned long Port);
__declspec(dllimport) unsigned short OutPortB        (              unsigned long Port, unsigned char Value);

__declspec(dllimport) unsigned short InPort          (              unsigned long Port);
__declspec(dllimport) unsigned short OutPort         (              unsigned long Port, unsigned short Value);

__declspec(dllimport) unsigned long  InPortL         (              unsigned long Port);
__declspec(dllimport) unsigned short OutPortL        (              unsigned long Port, unsigned long Value);
__declspec(dllimport) unsigned long  InPortDWord     (              unsigned long Port);
__declspec(dllimport) unsigned short OutPortDWord    (              unsigned long Port, unsigned long Value);

__declspec(dllimport) unsigned short RelInPortB      (long CardNum, unsigned long Port);
__declspec(dllimport) unsigned short RelOutPortB     (long CardNum, unsigned long Port, unsigned char Value);

__declspec(dllimport) unsigned short RelInPort       (long CardNum, unsigned long Port);
__declspec(dllimport) unsigned short RelOutPort      (long CardNum, unsigned long Port, unsigned short Value);

__declspec(dllimport) unsigned long  RelInPortL      (long CardNum, unsigned long Port);
__declspec(dllimport) unsigned short RelOutPortL     (long CardNum, unsigned long Port, unsigned long Value);
__declspec(dllimport) unsigned long  RelInPortDWord  (long CardNum, unsigned long Port);
__declspec(dllimport) unsigned short RelOutPortDWord (long CardNum, unsigned long Port, unsigned long Value);





#ifdef __cplusplus
}
#endif