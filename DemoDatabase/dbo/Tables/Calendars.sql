CREATE TABLE [dbo].[Calendars] (
    [Reserved_ElemDeleted]          CHAR (1)      NULL,
    [ProjectID]                     INT           NULL,
    [CalendarUniqueID]              INT           NULL,
    [BaseCalendarUniqueID]          INT           NULL,
    [ResourceUniqueID]              INT           NULL,
    [IsBaseCalendar]                BIT           NULL,
    [Reserved_CalendarAllocated]    BIT           NULL,
    [Reserved_IsNull]               BIT           NULL,
    [CalendarName]                  VARCHAR (255) NULL,
    [Reserved_PoolCalendarUniqueID] INT           NULL,
    [Reserved_BinaryProperties]     IMAGE         NULL,
    [MPD_ACTION_FLAG]               NUMERIC (2)   NULL
);

