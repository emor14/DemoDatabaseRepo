
CREATE procedure [dbo].[usp_calculateResourceLoadForProject_Rishi]
	@startDate date,
	@endDate date,
	@projID int 
as 
Begin
	declare @concSubtaskid int = 0;
	declare @subtaskId int
	declare @resourceType int
	declare @duration int
	declare @subTaskStartDate datetime
	declare @offset datetime
	declare @wiplimit int = 0
	declare @currentSubTasksInProgress int = 0
	declare @nextSubtaskID int = 0
	declare @topLevelTaskUnderProcess int = 0
	declare @subtaskType int = 0
	declare @subtaskCount int = 0
	declare @taskEndDatetime datetime

	truncate table TaskLoadByDay_Temp

	delete from TaskLoadByDay where ProjectId = @projID

	select 

				pt2.projectId,
				pt.taskUniqueId parentTaskId,
				pt2.taskUniqueId childTaskId,
				(case when pt.taskUniqueId = pt2.taskUniqueId then 0 else pt2.taskId end) executionOrder,
				(case when pt.EXPECTED_START_DATE < @startDate then @startDate else pt.EXPECTED_START_DATE end) startDate,
				pt.EXPECTED_START_DATE expected_start_date,
				pt.EXPECTED_END_DATE expected_end_date,
				(case when charindex('RT:', pt2.text_28) > 0 then substring(pt2.text_28, charindex('RT:', pt2.text_28), len(pt2.text_28)) else 'RT:1:Unknown[0]' end) text_28,
				pt2.DURATION,
				ptl.SUBTASK_TYPE,
				ptl.SUBTASK_WIP_LIMIT,
				cwt.calendarUniqueId,
				cwt.DayofWeek,
				(case when cwt.Working = 1 then 1 else 0 end) working,
				0 as finished
	into #tasks
	from
		project p
			inner join proj_task pt
				on	pt.projectId = p.projectId and
					pt.TASK_TYPE = 0 and
					pt.TASK_STATUS in (0, 1) and
					cast(IsNull(pt.EXPECTED_START_DATE, pt.STARTDATE) as date) <= @endDate and
					cast(IsNull(pt.EXPECTED_END_DATE, pt.FINISHDATE) as date) >= @startDate and
					pt.REMAININGDURATION > 0
				
			inner join proj_task_addl ptL
				on	ptl.projectId = pt.projectId and
					ptl.taskUniqueId = pt.taskUniqueId
				
			inner join proj_task_addl ptaddl
				on	ptaddl.projectId = pt.projectId and
					(case when ptaddl.parentTaskId = -1 then ptaddl.taskUniqueId else ptaddl.parentTaskId end) = pt.taskUniqueId
			inner join proj_task pt2
				on	pt2.projectId = ptaddl.projectId and
					pt2.taskUniqueId = ptaddl.taskUniqueId and
					pt2.TASK_STATUS in (0, 1) and
					pt2.REMAININGDURATION > 0
			left join Calendars c
				on	c.projectId = p.projectId and
					c.CalendarName = p.PROJECTCALENDARNAME
			left join Calendar_Working_Times cwt
				on	cwt.projectId = c.projectId and
					cwt.calendarUniqueId = c.calendarUniqueId and
					cwt.DayofWeek = datepart(W, pt.EXPECTED_START_DATE)
	where
		p.projectid = @projID and 
		p.checkin_filetype = 4 and
		p.project_type in (0, 2, 16) and
		p.division_name = 'WORSLEY'
	order by
		p.PROJECTID,
		pt.TASKID,
		(case when pt.taskUniqueId = pt2.taskUniqueId then 0 else pt2.taskId end)

	--select * from #tasks order by parentTaskId, executionorder-- TODO comment finally once the testing is over

	create table #concurrentSubtasks (id int identity(1,1), endDate datetime) 

	-- While there are top level tasks remaining to be processed 
	while exists(select top 1 1 from #tasks where finished = 0 and executionorder = 0) 
	begin
		 if not exists(select top 1 1 from #tasks where finished = 0 and 
			parentTaskId = @topLevelTaskUnderProcess and parentTaskId <> childTaskId)
		 begin
			-- This is the case when the current top level task has been processed completely. Mark it finished
			update #tasks set finished = 1 where childTaskId = @topLevelTaskUnderProcess
		
			--Also, start processing the next top level task
			select top 1 @subtaskType = subtask_type, @wiplimit = subtask_wip_limit, 
				@topLevelTaskUnderProcess = childTaskId, @offset = startDate 
			from #tasks where finished = 0 and parentTaskId = childTaskId order by childTaskId
	    
			-- Get the count of subtasks for this top level task
			select @subtaskCount = count(*) from #tasks where parentTaskId = @topLevelTaskUnderProcess 
				and childTaskId <> @topLevelTaskUnderProcess
		 
			--Adjust wip limit according to the type of the top level task			
			set @wiplimit = 
				case 
					when @subtaskType = 3 then @wiplimit --wip
					when @subtaskType = 1 then 1  -- sequential
					when @subtaskType = 4 then @subtaskCount  -- parallel
				end
			set @currentSubTasksInProgress = 1;

			-- #concurrentsubtasks table to control how many tasks can run in parallel. It always stores as many rows as @wiplimit, along with a timestamp. 
			-- Each row represents a slot that is available for starting a task The timestamp in the row always stores when the next task in that slot 
			-- can start. Whenever a subtask is started, the slot with min timestamp is chosen for it. 
			truncate table #concurrentSubtasks
		 end
		 else 
		 begin
			-- Start processing subtasks 
			while @currentSubTasksInProgress <= @subtaskCount
			begin
				if @currentSubTasksInProgress <= @wiplimit
				begin
					insert into #concurrentSubtasks select @offset
				end
			
				-- select the slot for this task, and the start date 
				select top 1 @concSubTaskId =  id, @subtaskStartDate = endDate from #concurrentSubtasks where
				endDate = (select min(enddate) from #concurrentSubtasks)     
		    
				select top 1 @subtaskId = childTaskId, @duration = DURATION from #tasks 
					where parentTaskId = @topLevelTaskUnderProcess 
				and finished = 0 and executionOrder > 0 order by executionOrder

				exec usp_calculateResourceLoadForTask_Rishi @projId, @subtaskId, @topLevelTaskUnderProcess, 
					@subTaskStartDate,@duration,@concSubTaskId,@wiplimit,@subtaskType,@taskEndDatetime output
				
				set @currentSubTasksInProgress = @currentSubTasksInProgress + 1
				update #concurrentSubtasks set endDate = @taskEndDatetime where id = @concSubTaskId
				update #tasks set finished = 1 where parentTaskId = @topLevelTaskUnderProcess and childTaskId = @subtaskId
			end 	 		
		 end  
	end

	if exists(select 1 from sysobjects where type = 'u' and name = '#concurrentSubtasks')
	drop table #concurrentSubtasks
	drop table #tasks

	--insert into TaskLoadByDay(ProjectId,ParentTaskId,ResourceTypeId,CalendarDay,Duration,Units)
	--select ProjectId,ParentTaskId,ResourceTypeId,[date],SUM([Hours])/MAX(Units),MAX(Units) 
	--from TaskLoadByDay_Temp
	--group by ParentTaskId,ProjectId,ResourceTypeId,[date]

	--truncate table TaskLoadByDay_Temp
end
