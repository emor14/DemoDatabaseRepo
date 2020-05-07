CREATE TABLE [dbo].[tasks] (
    [ID]                  INT           IDENTITY (1, 1) NOT NULL,
    [projectId]           FLOAT (53)    NOT NULL,
    [parentTaskId]        FLOAT (53)    NOT NULL,
    [childTaskId]         FLOAT (53)    NOT NULL,
    [executionOrder]      FLOAT (53)    NULL,
    [startDate]           DATETIME      NULL,
    [expected_start_date] DATETIME      NULL,
    [expected_end_date]   DATETIME      NULL,
    [text_28]             VARCHAR (255) NULL,
    [DURATION]            FLOAT (53)    NULL,
    [SUBTASK_TYPE]        SMALLINT      NULL,
    [SUBTASK_WIP_LIMIT]   NUMERIC (16)  NULL,
    [calendarUniqueId]    INT           NULL,
    [DayofWeek]           SMALLINT      NULL,
    [working]             INT           NOT NULL,
    [finished]            INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

