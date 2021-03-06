﻿CREATE TABLE [dbo].[PROJECT] (
    [PROJECTID]                      FLOAT (53)    NOT NULL,
    [PROJECTNAME]                    VARCHAR (255) NULL,
    [MANAGER_ID]                     VARCHAR (255) NULL,
    [CUSTOMER_ID]                    VARCHAR (255) NULL,
    [PROJECT_TYPE]                   FLOAT (53)    NULL,
    [PROJECTED_COMPLETION]           DATETIME      NULL,
    [EARLIEST_START]                 DATETIME      NULL,
    [STATUS]                         FLOAT (53)    NULL,
    [PRJ_PCT_BUFFER_SIZE_CCCB]       FLOAT (53)    NULL,
    [PRJ_CCCB_SIZE]                  FLOAT (53)    NULL,
    [PRJ_CCFB_SIZE]                  FLOAT (53)    NULL,
    [PRJ_CCRB_SIZE]                  FLOAT (53)    NULL,
    [PCT_TASK_REDUCTION]             FLOAT (53)    NULL,
    [PRJ_CMSB_SIZE]                  FLOAT (53)    NULL,
    [PRJ_PCT_BUFFER_SIZE_CCFB]       FLOAT (53)    NULL,
    [PRJ_PCT_BUFFER_SIZE_CMSB]       FLOAT (53)    NULL,
    [BM_LAST_UPDATE]                 DATETIME      NULL,
    [DS_LOCK]                        FLOAT (53)    NULL,
    [EXPORT_LAST_UPDATE]             DATETIME      NULL,
    [DIVISION_NAME]                  VARCHAR (255) NULL,
    [BP_PROJECTEDCOMPLETION]         DATETIME      NULL,
    [CC_OPTIMIZATION_FACTOR]         FLOAT (53)    NULL,
    [PRIORITY]                       FLOAT (53)    NULL,
    [FIXED]                          FLOAT (53)    NULL,
    [STRETCH]                        FLOAT (53)    NULL,
    [FINISHDATE]                     DATETIME      NULL,
    [CHECKOUTSTATUS]                 NUMERIC (6)   NULL,
    [CHECKOUTPATH]                   VARCHAR (255) NULL,
    [CHECKOUTUSER]                   VARCHAR (255) NULL,
    [CHECKINMPDVER]                  NUMERIC (6)   NULL,
    [OLD_PROJECTED_COMPLETION]       DATETIME      NULL,
    [PROJECTCALENDARNAME]            VARCHAR (255) NULL,
    [SUBJECT]                        VARCHAR (255) NULL,
    [AUTHOR]                         VARCHAR (255) NULL,
    [CATEGORY]                       VARCHAR (255) NULL,
    [TITLE]                          VARCHAR (255) NULL,
    [PROJECT_LOCKED]                 VARCHAR (255) NULL,
    [KEYWORDS]                       VARCHAR (255) NULL,
    [LASTUPDATETIMESTAMP]            VARCHAR (255) NULL,
    [DEFAULTSTARTTIME]               DATETIME      NULL,
    [DEFAULTFINISHTIME]              DATETIME      NULL,
    [DEFAULTMINUTESPERDAY]           NUMERIC (6)   NULL,
    [DEFAULTMINUTESPERWEEK]          NUMERIC (6)   NULL,
    [MAX_EXEC_TASK_UID]              NUMERIC (6)   NULL,
    [ENABLE_SUBTASKS]                NUMERIC (2)   NULL,
    [LOCKED_TIME]                    DATETIME      NULL,
    [LOCK_TYPE]                      NUMERIC (2)   NULL,
    [LOCKED_USER]                    VARCHAR (255) NULL,
    [ACCESS_LOCK]                    VARCHAR (255) NULL,
    [IGNOREVALUESABOVEPERCENT]       NUMERIC (10)  NULL,
    [PROJECTED_START_DATE]           DATETIME      NULL,
    [SCHEDULE_FLAGS]                 NUMERIC (16)  NULL,
    [PSIM_PROJECTED_DATE_TIMESTAMP]  DATETIME      NULL,
    [PSIM_PROJECTED_DATE_WITH_CAPB]  DATETIME      NULL,
    [PSIM_PROJECTED_DATE_WO_CAPB]    DATETIME      NULL,
    [MAX_CHECKLIST_UID]              NUMERIC (6)   NULL,
    [BM_HORIZON]                     DATETIME      NULL,
    [CALCHANGED]                     NUMERIC (2)   NULL,
    [CALDEFSECSDAY]                  NUMERIC (16)  NULL,
    [CHECKINTIMESTAMP]               DATETIME      NULL,
    [PROJECT_DESCRIPTOR]             NUMERIC (2)   NULL,
    [IS_SUBPROJECT]                  NUMERIC (2)   NULL,
    [PARENT_PROJECTID]               NUMERIC (16)  NULL,
    [PENCHAINTIMESTAMP]              DATETIME      NULL,
    [CHECKIN_FILETYPE]               NUMERIC (2)   NULL,
    [MSPROJECTFILEVER]               NUMERIC (6)   NULL,
    [CC_ALGORITHM_FLAGS]             NUMERIC (16)  NULL,
    [CC_FILE_VERSION]                FLOAT (53)    NULL,
    [ATTRIBUTE1]                     VARCHAR (255) NULL,
    [ATTRIBUTE2]                     VARCHAR (255) NULL,
    [ATTRIBUTE3]                     VARCHAR (255) NULL,
    [ATTRIBUTE4]                     VARCHAR (255) NULL,
    [ATTRIBUTE5]                     VARCHAR (255) NULL,
    [PIPELINE_COLOR]                 FLOAT (53)    NULL,
    [PLANNED_DATE]                   DATETIME      NULL,
    [WEIGHT]                         FLOAT (53)    NULL,
    [CUSTOM_DATE1]                   DATETIME      NULL,
    [CUSTOM_DATE2]                   DATETIME      NULL,
    [EXCLUDED_FOR_RR]                NUMERIC (2)   NULL,
    [PIPELINE_PROJECTED_DATE]        DATETIME      NULL,
    [PIPELINE_START_DATE]            DATETIME      NULL,
    [PIPELINE_PROJ_DATE_CT_STRETCH]  DATETIME      NULL,
    [PIPELINE_START_DATE_CT_STRETCH] DATETIME      NULL,
    [EXCLUSION_COMMENTS]             VARCHAR (255) NULL,
    [INHERIT_PROJ_CAL_FLAG]          NUMERIC (16)  NULL,
    [PCT_SUBTASK_REDUCTION]          NUMERIC (16)  NULL,
    [DURATION_ROUNDING_OPTION]       NUMERIC (16)  NULL,
    CONSTRAINT [PK_PROJECT] PRIMARY KEY CLUSTERED ([PROJECTID] ASC)
);

