CREATE TABLE [dbo].[tasks_Tuning] (
    [ID]               INT      IDENTITY (1, 1) NOT NULL,
    [projectId]        INT      NULL,
    [taskUniqueId]     INT      NULL,
    [subTaskUniqueId]  INT      NULL,
    [executionOrder]   INT      NULL,
    [SubtaskType]      INT      NULL,
    [SubtaskLimit]     INT      NULL,
    [duration]         INT      NULL,
    [calendarUniqueId] INT      NULL,
    [DayOfWeek]        INT      NULL,
    [Working]          BIT      NULL,
    [startDateTime]    DATETIME NULL,
    [endDateTime]      DATETIME NULL,
    [IsFinished]       INT      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

