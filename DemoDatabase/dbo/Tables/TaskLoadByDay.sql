CREATE TABLE [dbo].[TaskLoadByDay] (
    [ProjectId]      INT             NULL,
    [ParentTaskId]   INT             NULL,
    [SubtaskId]      INT             NULL,
    [date]           DATETIME        NULL,
    [Hours]          FLOAT (53)      NULL,
    [ResourceTypeId] INT             NULL,
    [units]          DECIMAL (25, 6) NULL,
    [starttime]      TIME (7)        NULL,
    [endtime]        TIME (7)        NULL,
    [slot]           INT             NULL
);

