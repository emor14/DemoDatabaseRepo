CREATE TABLE [dbo].[Calendar_Working_Times] (
    [Reserved_ElemDeleted] CHAR (1)    NULL,
    [ProjectID]            INT         NULL,
    [UniqueID]             INT         NULL,
    [CalendarUniqueID]     INT         NULL,
    [DayofWeek]            SMALLINT    NULL,
    [Working]              SMALLINT    NULL,
    [FromTime1]            DATETIME    NULL,
    [ToTime1]              DATETIME    NULL,
    [FromTime2]            DATETIME    NULL,
    [ToTime2]              DATETIME    NULL,
    [FromTime3]            DATETIME    NULL,
    [ToTime3]              DATETIME    NULL,
    [MPD_ACTION_FLAG]      NUMERIC (2) NULL
);

