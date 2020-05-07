CREATE TABLE [dbo].[TaskLoadByDay_Rishi] (
    [ProjectId]      INT        NULL,
    [ParentTaskId]   INT        NULL,
    [CalendarDay]    DATETIME   NULL,
    [Duration]       FLOAT (53) NULL,
    [ResourceTypeId] INT        NULL,
    [Units]          FLOAT (53) NULL,
    [SubtaskType]    INT        NULL,
    [SubtaskLimit]   INT        NULL
);

