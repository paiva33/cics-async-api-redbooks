       PROCESS CICS,NODYNAM,NSYMBOL(NATIONAL),TRUNC(STD)
      * Licensed Materials - Property of IBM
      *
      * SAMPLE
      *
      * (c) Copyright IBM Corp. 2017 All Rights Reserved
      *
      * US Government Users Restricted Rights - Use, duplication or
      * disclosure restricted by GSA ADP Schedule Contract with IBM Corp
      *
      ******************************************************************
      *  WEBHOME
      *
      * Is a CICS application example that supplies data to a 
      * simulated Web banking application.

      * This program is part of the CICS Asynchronous API Redbooks
      * Internet banking Example

      *
      * This example is driven via CICS terminal.
      * A customer account number (four digits)
      * is inputed into this parent coordinating program at a terminal
      * screen after running the initiating transaction
      * 'WEBH'
      * in the form:
      * WEBH nnnn
      * eg:
      * 'WEBH 0001'
      *
      *
      ******************************************************************
      *
      * **** NOTE ****
      * This is only an example to show the asynchronous API in a simple
      * form; in contrast to calling sub programs in a sequential manner
      *
      ******************************************************************

       IDENTIFICATION DIVISION.
        PROGRAM-ID. WEBHOME.
        AUTHOR. GOHILPR.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
        WORKING-STORAGE SECTION.  

      * Input record
       1 ACCOUNT-NUMBER-IN.
         2 CUST-NO-IN             PIC X(4).

      * Output record
       1 RETURN-DATA.
         2 CUSTOMER-NAME          PIC X(65) VALUE ' '.
         2 CUSTOMER-LOAN-RATE     PIC X(8)  VALUE ' '.
         2 CUSTOMER-ACCOUNTS.
          3 CURRENT-ACCOUNTS.
           4  NUMBER-OF-ACCOUNTS  PIC S9(4) COMP-5 SYNC VALUE 9.
           4  ACCOUNT-DETAILS OCCURS 5 TIMES.
            5  ACCT-NUMBER        PIC X(8) VALUE ' '.
            5  BALANCE            PIC X(8) VALUE ' '.
            5  OVERDRAFT          PIC X(8) VALUE ' '.
          3 PARTNER-ACCOUNTS.
           4  NUMBER-OF-ACCOUNTS  PIC S9(4) COMP-5 SYNC VALUE 9.
           4  ACCOUNT-DETAILS OCCURS 5 TIMES.
            5  ACCT-NUMBER        PIC X(8) VALUE ' '.
            5  BALANCE            PIC X(8) VALUE ' '.
            5  OVERDRAFT          PIC X(8) VALUE ' '.

      * For messages printed to the terminal screen
       1 TERMINAL-STATUS.
         2 PARENT-PROGRAM         PIC X(8)  VALUE 'WEBHOME'.
         2 FILLER                 PIC X(5)  VALUE ' ACC#'.
         2 ACCOUNT-NUM            PIC X(4)  VALUE '    '.
         2 FILLER                 PIC X(9)  VALUE ' STATUS( '.
         2 CURRENT-STATUS         PIC X(8)  VALUE 'RUNNING '.
         2 FILLER                 PIC X(2)  VALUE ' )'.

      * For messages displayed to the CICS log
       1 STATUS-MSG.
         2 MSG-TIME.
           3 MSG-HOUR            PIC X(2).
           3 FILLER              PIC X(1)  VALUE ':'.
           3 MSG-MIN             PIC X(2).
           3 FILLER              PIC X(1)  VALUE '.'.
           3 MSG-SEC             PIC X(2).
           3 FILLER              PIC X(1)  VALUE SPACES.
         2 MSG-TEXT              PIC X(61) VALUE ' '.

      * Maps the terminal input to obtain the account number
       1 READ-INPUT.
         2 TRANID                PIC X(4) VALUE '    '.
         2 FILLER                PIC X(1).
         2 INPUTACCNUM           PIC X(4) VALUE '    '.
       1 READ-INPUT-LENGTH       PIC S9(4) COMP-5 SYNC VALUE 9.

       1 CONTAINER-NAMES.
         2 INPUT-CONTAINER       PIC X(16) VALUE 'INPUTCONTAINER  '.
         2 GETNAME-CONTAINER     PIC X(16) VALUE 'GETNAMECONTAINER'.
         2 ACCTCURR-CONTAINER    PIC X(16) VALUE 'ACCTCURRCONT    '.

       1 MYCHANNEL               PIC X(16) VALUE 'MYCHANNEL       '.

       1 PROGRAM-NAMES.
         2 GET-NAME              PIC X(8) VALUE 'GETNAME '.
         2 ACCTCURR              PIC X(8) VALUE 'ACCTCURR'.
         2 ACCTPTNR              PIC X(8) VALUE 'ACCTPTNR'.
         2 GETLOAN               PIC X(8) VALUE 'GETLOAN '.

       1 CHILD-RETURN-STATUS     PIC S9(8) USAGE BINARY.
       1 CHILD-RETURN-ABCODE     PIC X(4).

       1 COMMAND-RESP            PIC S9(8) COMP.
       1 COMMAND-RESP2           PIC S9(8) COMP.

       1 COUNTER                 PIC S9(4) COMP-5 SYNC VALUE 9.

        LINKAGE SECTION.

       PROCEDURE DIVISION.

       MAINLINE SECTION.
      * --------------------------------------------------------------
      * Start of the main code execution
      * --------------------------------------------------------------

      * Display a message to easily identify start of execution
           INITIALIZE STATUS-MSG
           MOVE 'Started Web banking log-on data retrieval' TO MSG-TEXT
           PERFORM PRINT-STATUS-MESSAGE

      * First step is to retrieve the account number
           PERFORM GET-INPUT-ACCOUNT-NUMBER

      * ----
      * Create the input container for children to access
      * ----
           EXEC CICS PUT CONTAINER ( INPUT-CONTAINER )
                           FROM    ( ACCOUNT-NUMBER-IN )
                           CHANNEL ( MYCHANNEL)
                           RESP    ( COMMAND-RESP )
                           RESP2   ( COMMAND-RESP2 )
           END-EXEC

           PERFORM CHECK-COMMAND

      * ----
      * Get the customers name
      * ----
           EXEC CICS LINK PROGRAM ( GET-NAME )
                          CHANNEL ( MYCHANNEL )
                          RESP    ( COMMAND-RESP )
                          RESP2   ( COMMAND-RESP2 )
           END-EXEC

           PERFORM CHECK-COMMAND

           EXEC CICS GET CONTAINER ( GETNAME-CONTAINER )
                           CHANNEL ( MYCHANNEL )
                           INTO    ( CUSTOMER-NAME )
                           RESP    ( COMMAND-RESP )
                           RESP2   ( COMMAND-RESP2 )
           END-EXEC    

           PERFORM CHECK-COMMAND

           INITIALIZE STATUS-MSG
           STRING 'Welcome '
                  DELIMITED BY SIZE
                  CUSTOMER-NAME
                  DELIMITED BY SIZE
                INTO MSG-TEXT
           PERFORM PRINT-STATUS-MESSAGE

      * ----
      * Get the customers current account details
      * ----
           EXEC CICS LINK PROGRAM ( ACCTCURR )
                          CHANNEL ( MYCHANNEL )
                          RESP    ( COMMAND-RESP )
                          RESP2   ( COMMAND-RESP2 )
           END-EXEC

           PERFORM CHECK-COMMAND

           EXEC CICS GET CONTAINER ( ACCTCURR-CONTAINER )
                           CHANNEL ( MYCHANNEL )
                           INTO    ( CURRENT-ACCOUNTS )
                           RESP    ( COMMAND-RESP )
                           RESP2   ( COMMAND-RESP2 )
           END-EXEC

           PERFORM CHECK-COMMAND

           PERFORM PRINT-CURRENT-ACCOUNTS-DETAILS

      * Send a message to the screen to
      * notify terminal user of completion
           MOVE 'COMPLETE' TO CURRENT-STATUS
           PERFORM PRINT-TEXT-TO-SCREEN

      * Display a conclusion message that also includes a timestamp
           INITIALIZE STATUS-MSG
           MOVE 'Ended Web banking log-on data retrieval' TO MSG-TEXT
           PERFORM PRINT-STATUS-MESSAGE

      * Return at end of program
           EXEC CICS RETURN
           END-EXEC
           .
      * --------------------------------------------------------------
      * End of the main code execution
      * --------------------------------------------------------------

      * --------------------------------------------------------------
      * Below are helpful procedures and routines
      * --------------------------------------------------------------

      * Retrieve the customer account number, which should be
      * specified on the terminal command after the transaction ID.
       GET-INPUT-ACCOUNT-NUMBER.
           EXEC CICS RECEIVE INTO       ( READ-INPUT )
                             LENGTH     ( READ-INPUT-LENGTH )
                             NOTRUNCATE
                             RESP       ( COMMAND-RESP )
                             RESP2      ( COMMAND-RESP2 )
           END-EXEC

           IF INPUTACCNUM = '    '
           THEN 
      * if we failed to locate an account number, continue with 9999
             MOVE '9999' TO CUST-NO-IN
             MOVE '9999' TO ACCOUNT-NUM
           ELSE
             MOVE INPUTACCNUM TO CUST-NO-IN
             MOVE INPUTACCNUM TO ACCOUNT-NUM
           END-IF

      * Send a message to the screen to
      * notify terminal user that the application is running
           PERFORM PRINT-TEXT-TO-SCREEN
           .

      * Print current account details
       PRINT-CURRENT-ACCOUNTS-DETAILS.
           IF NUMBER-OF-ACCOUNTS OF CURRENT-ACCOUNTS > 0 THEN
             MOVE 1 TO COUNTER
             PERFORM UNTIL COUNTER > 
                       NUMBER-OF-ACCOUNTS OF CURRENT-ACCOUNTS
               INITIALIZE STATUS-MSG
               STRING 'Acc: '
                      DELIMITED BY SIZE
                      ACCT-NUMBER OF CURRENT-ACCOUNTS (COUNTER)
                      DELIMITED BY SPACE
                      ' Bal: $'
                      DELIMITED BY SIZE
                      BALANCE OF CURRENT-ACCOUNTS (COUNTER)
                      DELIMITED BY SIZE
                      ' Overdraft: $'
                      DELIMITED BY SIZE
                      OVERDRAFT OF CURRENT-ACCOUNTS (COUNTER)
                      DELIMITED BY SIZE
                    INTO MSG-TEXT
               PERFORM PRINT-STATUS-MESSAGE
               ADD 1 TO COUNTER
             END-PERFORM
           END-IF
           .

      * Print status message
       PRINT-STATUS-MESSAGE.
           MOVE FUNCTION CURRENT-DATE(13:2) TO MSG-SEC
           MOVE FUNCTION CURRENT-DATE(11:2) TO MSG-MIN
           MOVE FUNCTION CURRENT-DATE(9:2)  TO MSG-HOUR

           DISPLAY STATUS-MSG
           .

      * update terminal screen with progress status
       PRINT-TEXT-TO-SCREEN.
           EXEC CICS SEND TEXT FROM ( TERMINAL-STATUS )
                     TERMINAL WAIT
                     FREEKB
                     ERASE
           END-EXEC
           .

      * Routine to check command
       CHECK-COMMAND.
           IF COMMAND-RESP NOT = DFHRESP(NORMAL)
           THEN
             PERFORM WEBHOME-ERROR
           END-IF
           .

      * Routine to check child completion status
      * For simplicity, we simply exit.
      * It could be useful to print further details, such as abcode
       CHECK-CHILD.
           IF CHILD-RETURN-STATUS NOT = DFHVALUE(NORMAL)
           THEN
             PERFORM WEBHOME-ERROR
           END-IF
           .

      * Error path processing to write messages and abend
       WEBHOME-ERROR.
      * Send a error status message
           INITIALIZE STATUS-MSG
           MOVE '*** Error occurred in WEBHOME.' TO MSG-TEXT
           PERFORM PRINT-STATUS-MESSAGE

      * Send a message to the terminal screen 
           MOVE 'FAILED' TO CURRENT-STATUS
           PERFORM PRINT-TEXT-TO-SCREEN

           EXEC CICS ABEND ABCODE('WEBH') NODUMP END-EXEC
           .

       END PROGRAM 'WEBHOME'.