CREATE TABLE [dbo].[LoadByDayByResourceType_New] (
    [projectId]      INT        NULL,
    [taskUniqueId]   INT        NULL,
    [resourceTypeId] INT        NULL,
    [units]          FLOAT (53) NULL,
    [duration]       FLOAT (53) NULL,
    [calendarDay]    DATE       NULL,
    [processType]    INT        NULL,
    [processLimit]   INT        NULL
);

