
/****** Object:  UserDefinedFunction [dbo].[getResourceLoadByDay_NP]    Script Date: 06-Apr-20 11:26:20 AM ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	
-- This function takes a subtask details like its project, parent task, the startdatetime, and duration,
-- and calculates how much time each resource type is supposed to spend on the task from start to finish
-- =============================================
CREATE FUNCTION [dbo].[getResourceLoadByDay] 
(
	@projectId int,
	@subTaskId int,
	@parentTaskId int,
	@startDatetime datetime,
	@duration float
)
RETURNS 
@result TABLE 
(
	resourceTypeId int,
	units decimal(25,6),
	dt datetime,
	duration float,
	endTimeForDay datetime
)
AS
BEGIN
	declare @resourceTypeId int
	declare @units decimal(25,6) 
	declare @calendarId int
    declare @dayofweek int
	declare @startTime time 
	declare @ft1 time
	declare @tt1 time
	declare @ft2 time
	declare @tt2 time
	declare @ft3 time
	declare @tt3 time
	declare @durationInSec float = @duration * 6 -- Duration of the task in seconds
	declare @durationForTheDay float = 0;
	declare @endTimeForDay datetime -- The time at which the work for the task ends on a day  
	declare @tblResourceTypes table (resourceTypeID int, units int, calendarID int, processed int)

	insert into @tblResourceTypes (resourceTypeID, units, calendarID, processed)
		select ai.ResourceUniqueID, Units, CalendarUniqueID, 0 from dbo.Assignment_Information ai inner join project p
		on p.PROJECTID = ai.ProjectID inner join Calendars c
		on (c.ProjectID = p.ProjectID and p.PROJECTCALENDARNAME =c.CalendarName ) 
		where ai.ProjectID = @projectId and TaskUniqueID = @subTaskId 
	
	while exists (select * from @tblResourceTypes where processed = 0)
	begin
	    select top 1 @CalendarId = CalendarId, @units = units, @resourceTypeId = resourceTypeID  from @tblResourceTypes where processed = 0    
		while @durationInsec > 0 
		begin
			set @durationForTheDay = 0
			set @dayOfWeek = datepart(dw, @startDatetime)
			set @startTime = cast (@startDatetime as time)
			if exists (select * from Calendar_Working_Times where projectId = @projectId and CalendarUniqueID = @calendarId and [DayofWeek] = @dayofweek and working = 1)
			begin
				select @ft1 = cast (fromtime1 as time), @ft2 = cast(fromtime2 as time), @ft3 = cast(fromtime3 as time),
				@tt1 = cast(totime1 as time), @tt2 = cast(totime2 as time), @tt3 = cast(totime3 as time) from Calendar_Working_Times
				where projectId = @projectId and CalendarUniqueID = @calendarId and [DayofWeek] = @dayofweek
			
				if @startTime < @ft1 
				begin
					set @durationInsec = @durationInSec - datediff(SECOND,  @ft1, @tt1)
					set @durationForTheDay = @durationForTheDay + datediff(SECOND,  @ft1, @tt1) + (case when @durationInSec < 0 then @durationInSec else 0 end)  
					set @endTimeForDay = DATEADD(SECOND,  datediff(SECOND,  @ft1, @tt1) + (case when @durationInSec < 0 then @durationInSec else 0 end),@ft1) 
					set @startTime = @ft2
				
				end 
				else if @startTime between @ft1 and @tt1
				begin
					set @durationInsec = @durationInSec - datediff(SECOND,  @startTime, @tt1)
					set @durationForTheDay = @durationForTheDay + datediff(SECOND,  @startTime, @tt1) + (case when @durationInSec < 0 then @durationInSec else 0 end)
					set @endTimeForDay = DATEADD(SECOND,  datediff(SECOND,  @startTime, @tt1) + (case when @durationInSec < 0 then @durationInSec else 0 end), @startTime)
					set @startTime = @ft2
				end
			
				if @durationInSec > 0
				begin
					if @startTime < @ft2 
					begin
						set @durationInsec = @durationInSec - datediff(SECOND,  @ft2, @tt2)
						set @durationForTheDay = @durationForTheDay + datediff(SECOND,  @ft2, @tt2) + (case when @durationInSec < 0 then @durationInSec else 0 end)
						set @endTimeForDay = DATEADD(SECOND,  datediff(SECOND,  @ft2, @tt2) + (case when @durationInSec < 0 then @durationInSec else 0 end),@ft2) 
						set @startTime = @ft3
					end 
					else if @startTime between @ft2 and @tt2
					begin
						set @durationInsec = @durationInSec - datediff(SECOND,  @startTime, @tt2)
						set @durationForTheDay = @durationForTheDay + datediff(SECOND,  @startTime, @tt2) + (case when @durationInSec < 0 then @durationInSec else 0 end)
						set @endTimeForDay = DATEADD(SECOND,  datediff(SECOND,  @startTime, @tt2) + (case when @durationInSec < 0 then @durationInSec else 0 end),@startTime) 
						set @startTime = @ft3
					end
				end

				if @durationInSec > 0
				begin
					if @startTime < @ft3 
					begin
						set @durationInsec = @durationInSec - datediff(SECOND,  @ft3, @tt3)
						set @durationForTheDay = @durationForTheDay + datediff(SECOND,  @ft3, @tt3) + (case when @durationInSec < 0 then @durationInSec else 0 end)
						set @endTimeForDay = DATEADD(SECOND,  datediff(SECOND,  @ft3, @tt3) + (case when @durationInSec < 0 then @durationInSec else 0 end),@ft3)
					end 
					else if @startTime between @ft3 and @tt3
					begin
						set @durationInsec = @durationInSec - datediff(SECOND,  @startTime, @tt3)
						set @durationForTheDay = @durationForTheDay + datediff(SECOND,  @startTime, @tt3) + (case when @durationInSec < 0 then @durationInSec else 0 end)
						set @endTimeForDay = DATEADD(SECOND,  datediff(SECOND,  @startTime, @tt3) + (case when @durationInSec < 0 then @durationInSec else 0 end),@startTime)
					end
				end 
				insert into @result(resourceTypeId,units,dt,duration,endTimeForDay) select 
					@resourceTypeId,@units, cast(@startDatetime as date),@durationForTheDay, (cast(cast(@startDatetime as date) as datetime) + cast(@endTimeForDay as datetime)  )
				if @durationInSec > 0
				begin
					set @startDateTime = cast ( cast (DATEADD(DAY, 1,@startDatetime) as date) as datetime)
				end
			     	
			end 
			else
			begin
				set @startDateTime = cast ( cast (DATEADD(DAY, 1,@startDatetime) as date) as datetime)
			end
		end
		update @tblResourceTypes set processed = 1 where resourceTypeID = @resourceTypeId 
	end
	return
END

