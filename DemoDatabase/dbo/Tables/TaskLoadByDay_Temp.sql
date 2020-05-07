CREATE TABLE [dbo].[TaskLoadByDay_Temp] (
    [ProjectId]      INT             NULL,
    [ParentTaskId]   INT             NULL,
    [SubtaskId]      INT             NULL,
    [StartDateTime]  DATETIME        NULL,
    [Hours]          FLOAT (53)      NULL,
    [ResourceTypeId] INT             NULL,
    [units]          DECIMAL (25, 6) NULL,
    [StartDate]      DATE            NULL,
    [StartTime]      TIME (0)        NULL,
    [EndTime]        TIME (0)        NULL,
    [IsProcessed]    INT             CONSTRAINT [DF_TaskLoadByDay_Temp_IsProcessed] DEFAULT ((0)) NULL,
    [WipLimit]       INT             NULL,
    [SubtaskType]    INT             NULL,
    [Slot]           INT             NULL
);

