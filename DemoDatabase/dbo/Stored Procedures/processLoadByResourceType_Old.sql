CREATE procedure [dbo].[processLoadByResourceType_Old] (@startDate date, @endDate date) as
begin
	set nocount on
				
	declare
		--@startDate date = cast(getdate() as date),
		--@endDate date = cast(dateadd(month, 6, getdate()) as date),
		@projectId int,
		@taskUniqueId int,
		@subTaskUniqueId int,
		@executionOrder int,
		@EXPECTED_START_DATE datetime,
		@EXPECTED_END_DATE datetime,
		@text_28 varchar(500),
		@DURATION float,
		@_DURATION float,
		@SUBTASK_TYPE int,
		@SUBTASK_WIP_LIMIT int,
		@CalDate datetime,
		@calendarUniqueId int,
		@DayOfWeek int,
		@Working bit,
				
		@resourceTypeId int,
		@resourceTypeUnits float,
				
		@bLoop bit = 1,
				
		@previousCalDate datetime = null,
		@previousProjectId int = null,
		@previousTaskUniqueId int = null,
		@previousResourceTypeId int = null,
				
		@previousSUBTASK_TYPE int,
		@previousSUBTASK_WIP_LIMIT int,
				
		@previousWorking bit,
		@previousCalendarUniqueId int,
		@previousDayOfWeek int,
		@previousStartDate date = null,
				
		@resourceUnits float = null,
				
		@wip int,
				
		@durationUnits varchar(500) = null,
		@workDurationUnits varchar(500) = null,
		@rtd int,
		@rtu float,
		@minDuration int = null,
		@maxDuration int = null,
		@minDur int = null,
				
		@startDateTime datetime = null,
		@_startDateTime datetime = null,
		@endDateTime datetime = null,
		@minEndDateTime datetime = null,
		@maxEndDateTime datetime = null,
				
		@minDurationUnits float = null,
		@maxUnits float = null,
				
		@moveStartTimeOffSet float,
		@startTimeOffSet float,
				
		@days int,
		@dayValues varchar(max),
		@dayValue varchar(max),
				
		@previousDuration float,

		@text28 varchar(500)
				
	create table #tasks
	(
		projectId int,
		taskUniqueId int,
		subTaskUniqueId int,
		executionOrder int,
		processType int,
		processLimit int,
		duration int,
		calendarUniqueId int,
		DayOfWeek int,
		Working bit,
		startDateTime datetime,
		endDateTime datetime,
	)

				
	create table #resourceTypesByTask
	(
		projectId int,
		taskUniqueId int,
		subTaskUniqueId int,
		resourceTypeId int,
		units int
	)
	
				
	declare curTasks cursor for
		select
			pt2.projectId,
			pt.taskUniqueId,
			pt2.taskUniqueId,
			(case when pt.taskUniqueId = pt2.taskUniqueId then 0 else pt2.taskId end) executionOrder,
			(case when pt.EXPECTED_START_DATE < @startDate then @startDate else pt.EXPECTED_START_DATE end),
			pt.EXPECTED_END_DATE,
			(case when charindex('RT:', pt2.text_28) > 0 then substring(pt2.text_28, charindex('RT:', pt2.text_28), len(pt2.text_28)) else 'RT:1:Unknown[0]' end) text_28,
			pt2.DURATION,
			ptl.SUBTASK_TYPE,
			ptl.SUBTASK_WIP_LIMIT,
			cwt.calendarUniqueId,
			cwt.DayofWeek,
			(case when cwt.Working = 1 then 1 else 0 end)
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
			p.checkin_filetype = 4 and
			p.project_type in (0, 2, 16) and
			p.division_name = 'WORSLEY'
		order by
			p.PROJECTID,
			pt.TASKID,
			(case when pt.taskUniqueId = pt2.taskUniqueId then 0 else pt2.taskId end)
	 
	--
	--Retrieving task by resource type
	--
	open curTasks 
				 
	while @bLoop = 1
		begin
			fetch curTasks into
				@projectId,
				@taskUniqueId,
				@subTaskUniqueId,
				@executionOrder,
				@EXPECTED_START_DATE,
				@EXPECTED_END_DATE,
				@text_28,
				@DURATION,
				@SUBTASK_TYPE,
				@SUBTASK_WIP_LIMIT,
				@calendarUniqueId,
				@DayOfWeek,
				@Working
				 
			if @@fetch_status = 0
				begin
				 	if ((@text_28 is not null) and (@taskUniqueId <> @subTaskUniqueId))
				 		begin
				 			insert #tasks
				 			(
				 				projectId,
				 				taskUniqueId,
				 				subTaskUniqueId,
				 				executionOrder,
				 				processType,
				 				processLimit,
				 				duration,
				 				calendarUniqueId,
				 				dayOfWeek,
				 				working,
				 				startDateTime
				 			)
				 			values
				 			(
				 				@projectId,
				 				@taskUniqueId,
				 				@subTaskUniqueId,
				 				@executionOrder,
				 				@SUBTASK_TYPE,
				 				@SUBTASK_WIP_LIMIT,
				 				@DURATION,
				 				@calendarUniqueId,
				 				@dayOfWeek,
				 				@working,
				 				@EXPECTED_START_DATE
				 			)
				 
				 			--Process resource by task
				 			insert #resourceTypesByTask
				 			(
				 				projectId,
				 				taskUniqueId,
				 				subTaskUniqueId,
				 				resourceTypeId,
				 				units
				 			)
							select
								ai.ProjectID,
								@taskUniqueId,
								ai.TaskUniqueID,
								ai.ResourceUniqueID,
								ai.Units
							from
								assignment_information ai
							where
								ai.projectId = @projectId and
								ai.TaskUniqueID = @subTaskUniqueId

							if @@ROWCOUNT = 0
				 				insert #resourceTypesByTask
				 				(
				 					projectId,
				 					taskUniqueId,
				 					subTaskUniqueId,
				 					resourceTypeId,
				 					units
				 				)
								select
									pr.ProjectID,
									@taskUniqueId,
									@subTaskUniqueId,
									pr.ResourceUniqueID,
									1
								from
									proj_resource pr
								where
									pr.projectId = @projectId and
									pr.ResourceUniqueID = 1
							--else
				 		end
				 	--else
				end
			else
				set @bLoop = 0
		end
				 
	close curTasks
	deallocate curTasks
	
				 
	select top 0 * into #movedTasks from #tasks
				 
	--
	--Step 1 - Moving task based on process type
	--
	declare curTasks cursor for
		select
			projectId,
			taskUniqueId,
			subTaskUniqueId,
			executionOrder,
			processType,
			processLimit,
			duration,
			calendarUniqueId,
			dayOfWeek,
			working,
			startDateTime
		from
			#tasks
		order by
			projectId,
			taskUniqueId,
			executionOrder
		 
	set @bLoop = 1
	set @previousDuration = 0
				 
	open curTasks
				 
	while @bLoop = 1
		begin
			fetch curTasks into
				@projectId,
				@taskUniqueId,
				@subTaskUniqueId,
				@executionOrder,
				@SUBTASK_TYPE,
				@SUBTASK_WIP_LIMIT,
				@DURATION,
				@calendarUniqueId,
				@dayOfWeek,
				@working,
				@EXPECTED_START_DATE
				 
			if @@fetch_status = 0
				begin
				 	if
				 		(
				 		(@previousProjectId is null) or
				 		(@previousProjectId <> @projectId) or
				 		(@previousTaskUniqueId is null) or
				 		(@previousTaskUniqueId <> @taskUniqueId)
				 	)
				 		begin
				 			select
				 				@previousProjectId = @projectId,
				 				@previousTaskUniqueId = @taskUniqueId,
				 				@previousSUBTASK_TYPE = @SUBTASK_TYPE,
				 				@previousSUBTASK_WIP_LIMIT = @SUBTASK_WIP_LIMIT,
				 				@previousCalendarUniqueId = @calendarUniqueId,
				 				@previousDayOfWeek = @dayOfWeek,
				 				@previousWorking = @working,
				 				@wip = 0,
				 				@durationUnits = '',
				 				@minDur = @DURATION,
				 				@minDuration = @DURATION,
				 				@maxDuration = @DURATION,
				 				@startTimeOffSet = 0,
				 				@moveStartTimeOffSet = 0,
				 				@resourceTypeUnits = 0,
				 				@previousDuration = 0
				 		end
				 	--else
				 
				 	--> 3-WIP
				 	if @SUBTASK_TYPE = 3 and @SUBTASK_WIP_LIMIT > 1
				 		begin
				 			if @wip = @SUBTASK_WIP_LIMIT
				 				begin
									declare
										@tasksInProcess int = 0,
										@tasksFinished int = 0;

				 					set @workDurationUnits = ''
				 					set @minDur = @maxDuration
				 
				 					set @durationUnits = @durationUnits + '|'
				 
				 					while (len(@durationUnits) > 0)
				 						begin
											set @tasksInProcess = @tasksInProcess + 1

				 							set @rtd = cast(substring(@durationUnits, 1, charindex(':', @durationUnits) - 1) as float)
				 							set @durationUnits = substring(@durationUnits, charindex(':', @durationUnits) + 1, len(@durationUnits))
				 							set @rtu = cast(substring(@durationUnits, 1, charindex('|', @durationUnits) - 1) as float)
				 							set @durationUnits = substring(@durationUnits, charindex('|', @durationUnits) + 1, len(@durationUnits))
				 
				 							set @rtd = @rtd - @minDuration
				 							if @rtd  = 0
												begin
				 									set @moveStartTimeOffSet = @minDuration
													set @wip = @wip - 1
													set @tasksFinished = @tasksFinished + 1
												end
				 							else
				 								begin
				 									set @workDurationUnits = (case when len(@workDurationUnits) > 0 then (@workDurationUnits + '|') else '' end) + cast(@rtd as varchar) + ':' + cast(@rtu as varchar)
				 									set @minDur = (case when @minDur < @rtd then @minDur else @rtd end)
				 								end
				 						end
				 
									if @tasksInProcess = @tasksFinished
										begin
				 							set @maxDuration = @duration
				 							set @minDuration = @duration
										end
									else
										begin
				 							set @maxDuration = @maxDuration - @minDuration
				 							set @minDuration = @minDur
										end

				 					set @durationUnits = @workDurationUnits
				 					set @minDuration = (case when @minDuration < @duration then @minDuration else @duration end)
				 					set @maxDuration = (case when @maxDuration > @duration then @maxDuration else @duration end)
				 				end
				 			--else
				 
				 			set @minDuration = (case when @minDuration < @duration then @minDuration else @duration end)
				 			set @maxDuration = (case when @maxDuration > @duration then @maxDuration else @duration end)
				 			set @durationUnits = (case when len(@durationUnits) > 0 then (@durationUnits + '|') else '' end) + cast(@duration as varchar) + ':' + cast(@resourceTypeUnits as varchar)
				 			set @wip = @wip + 1
				 		end
				 	else
				 		if @SUBTASK_TYPE <> 4
				 			set @moveStartTimeOffSet = @previousDuration
				 		--else
				 
				 	if @moveStartTimeOffSet > 0
						begin
				 			set @startTimeOffSet = @startTimeOffSet + @moveStartTimeOffSet
							set @moveStartTimeOffSet = 0
						end
				 	--else
				 
				 	set @previousDuration = @duration
				 
				 	--
				 	--Adjust the task start time
				 	--
				 	select
				 		@startDateTime = targetDateTime,
				 		@dayOfWeek = cast(IsNull(dayValues, '0') as int)
				 	from
				 		dbo.retrieveNextWorkingDay(@projectId, @calendarUniqueId, @EXPECTED_START_DATE, @startTimeOffSet, @duration)
				 
				 	--
				 	--Adjust the task end time
				 	--
				 	select
				 		@endDateTime = targetDateTime,
				 		@days = days,
				 		@dayValues = dayValues
				 	from
				 		dbo.retrieveNextWorkingDay(@projectId, @calendarUniqueId, @startDateTime, @duration, 0)
				 	
				 	while len(@dayValues) > 0
					begin

				 			set @dayValue = subString(@dayValues, 1, charIndex(';', @dayValues) - 1)
				 			set @dayValues = subString(@dayValues, charIndex(';', @dayValues) + 1, len(@dayValues))
				 
				 			--Duration
				 			set @DURATION = (cast(substring(@dayValue, 1, charindex(':', @dayValue) - 1) as float) / 6)
				 			set @dayValue = subString(@dayValue, charIndex(':', @dayValue) + 1, len(@dayValue))
				 
				 			--StartDateTime
				 			if(charindex('|', @dayValue) > 0)
				 				begin
				 					set @startDateTime = convert(datetime, substring(@dayValue, 1, charindex('|', @dayValue) - 1), 121)
				 					set @dayValue = substring(@dayValue, charindex('|', @dayValue) + 1, len(@dayValue))
				 				end
				 			--else
				 
				 			--EndDateTime
				 			set @endDateTime = convert(datetime, @dayValue, 121)
				 
				 			if @duration > 0
				 				insert into #movedTasks
				 				select
				 					trt.projectId,
				 					trt.taskUniqueId,
				 					trt.subTaskUniqueId,
				 					trt.executionOrder,
				 					trt.processType,
				 					trt.processLimit,
				 					@DURATION,
				 					trt.calendarUniqueId,
				 					@DayOfWeek,
				 					trt.Working,
				 					@startDateTime,
				 					@endDateTime
				 				from
				 					#tasks trt
				 				where
				 					trt.projectId = @projectId and
				 					trt.taskUniqueId = @taskUniqueId and
				 					trt.subTaskUniqueId = @subTaskUniqueId and
				 					trt.executionOrder = @executionOrder
				 			--else
				 
				 			set @days = @days - 1
				 		end
		
				end
			else
				set @bLoop = 0
		end
				 
	close curTasks
	deallocate curTasks
			 
	create table #maxResourceTypeUnitsDurationByDay
	(
		projectId int,
		taskUniqueId int,
		resourceTypeId int,
		calendarDay date,
		units float,
		duration float
	)
				 
	--
	--Step 2 - Process Sequential tasks
	--
	insert into #maxResourceTypeUnitsDurationByDay
	select
		mt.projectId,
		mt.taskUniqueId,
		rtt.resourceTypeId,
		cast(mt.startDateTime as date),
		max(rtt.units),
		sum(mt.duration)
	from
		#movedTasks mt
			inner join #resourceTypesByTask rtt
				on	rtt.projectId = mt.projectId and
				 	rtt.taskUniqueId = mt.taskUniqueId and
				 	rtt.subTaskUniqueId = mt.subTaskUniqueId
	where
		(mt.processType = 1) or -- Sequential
		(
			mt.processType = 3 and -- WIP 1 -> Sequential
			mt.processLimit = 1
		)
	group by
		mt.projectId,
		mt.taskUniqueId,
		rtt.resourceTypeId,
		cast(mt.startDateTime as date)
				 
	--
	-- Step 3 - Process Parallel tasks
	--
	insert into #maxResourceTypeUnitsDurationByDay
	select
		mt.projectId,
		mt.taskUniqueId,
		rtt.resourceTypeId,
		cast(mt.startDateTime as date),
		sum(rtt.units),
		max(mt.duration)
	from
		#movedTasks mt
			inner join #resourceTypesByTask rtt
				on	rtt.projectId = mt.projectId and
				 	rtt.taskUniqueId = mt.taskUniqueId and
				 	rtt.subTaskUniqueId = mt.subTaskUniqueId
	where
		mt.processType = 4
	group by
		mt.projectId,
		mt.taskUniqueId,
		rtt.resourceTypeId,
		cast(mt.startDateTime as date)
				 
	--
	--Step 4 - Process WIP tasks
	--
	create table #wipControl
	(
		resourceTypeId int,
		wip bit,
		units float,
		duration float,
		minDuration float,
		maxDuration float
	)
				 
	declare curTasks cursor for
		select
			projectId,
			taskUniqueId,
			subTaskUniqueId,
			executionOrder,
			processType,
			processLimit,
			duration,
			calendarUniqueId,
			dayOfWeek,
			working,
			startDateTime
		from
			#movedTasks
		where
			processType = 3 and
			processLimit > 1
		order by
			projectId,
			taskUniqueId,
			startDateTime,
			executionOrder
		for READ ONLY	 
	set @bLoop = 1
				 
	select
		@previousProjectId = null,
		@previousTaskUniqueId = null,
		@previousStartDate = null,
		@wip = 0
				 
	open curTasks
				 
	while @bLoop = 1
		begin
			fetch curTasks into
				@projectId,
				@taskUniqueId,
				@subTaskUniqueId,
				@executionOrder,
				@SUBTASK_TYPE,
				@SUBTASK_WIP_LIMIT,
				@DURATION,
				@calendarUniqueId,
				@dayOfWeek,
				@working,
				@startDateTime
				 
			if @@fetch_status = 0
				begin
				 	if
				 		(
				 		(@previousProjectId is null) or
				 		(@previousProjectId <> @projectId) or
				 		(@previousTaskUniqueId is null) or
				 		(@previousTaskUniqueId <> @taskUniqueId) or
				 		(@previousStartDate is null) or
				 		(@previousStartDate <> cast(@startDateTime as date))
				 	)
				 		begin
				 			if
				 			(
				 				(@previousProjectId is not null) and
				 				(@previousTaskUniqueId is not null) and
				 				(@previousStartDate is not null)
				 			)
				 				begin
				 					insert into #maxResourceTypeUnitsDurationByDay
				 					(
				 						projectId,
				 						taskUniqueId,
				 						resourceTypeId,
				 						units,
				 						duration,
				 						calendarDay
				 					)
				 					select
				 						@previousProjectId,
				 						@previousTaskUniqueId,
				 						resourceTypeId,
				 						units,
				 						(duration + maxDuration) / 600.0,
				 						@previousStartDate
				 					from
				 						#wipControl
				 					where
				 						wip = 0 and
				 						units > 0
				 				end
				 			--else
				 
				 			truncate table #wipControl
				 
				 			select
				 				@previousProjectId = @projectId,
				 				@previousTaskUniqueId = @taskUniqueId,
				 				@previousStartDate = cast(@startDateTime as date),
				 				@wip = 0,
				 				@durationUnits = '',
				 				@resourceUnits = 0,
				 				@maxUnits = 0,
				 				@minDur = @DURATION,
				 				@minDuration = @DURATION,
				 				@maxDuration = @DURATION,
				 				@startTimeOffSet = 0,
				 				@moveStartTimeOffSet = 0
				 		end
				 	--else
				 
				 	--> 3-WIP
				 	if @wip = 0
				 		begin
				 			insert into #wipControl
				 			(
				 				resourceTypeId,
				 				wip,
				 				units,
				 				duration,
				 				minDuration,
				 				maxDuration
				 			)
				 			select distinct
				 				resourceTypeId,
				 				0,
				 				0,
				 				0,
				 				0,
				 				0
				 			from
				 				#resourceTypesByTask
				 			where
				 				projectId = @projectId and
				 				taskUniqueId = @taskUniqueId
				 		end
				 	else
				 		if @wip = @SUBTASK_WIP_LIMIT
				 			begin
				 				delete
				 					wip1
				 				from
				 					#wipControl wip1
				 						inner join #wipControl wip0
				 							on	wip0.resourceTypeId = wip1.resourceTypeId and
				 								wip0.wip = 0
				 				where
				 					wip1.wip = 1 and
				 					round((wip1.duration - wip0.minDuration), 0) = 0
				 
				 				update
				 					#wipControl
				 				set
				 					duration = duration + minDuration,
				 					minDuration = maxDuration - minDuration,
				 					maxDuration = maxDuration - minDuration
				 				where
				 					wip = 0
				 
				 				select
				 					@wip = count(1)
				 				from
				 					#wipControl
				 				where
				 					wip = 1
				 			end
				 		--else
				 
				 	insert into #wipControl
				 	(
				 		resourceTypeId,
				 		wip,
				 		units,
				 		duration
				 	)
				 	select
				 		resourceTypeId,
				 		1,
				 		units,
				 		@DURATION * 600.0
				 	from
				 		#resourceTypesByTask
				 	where
				 		projectId = @projectId and
				 		taskUniqueId = @taskUniqueId and
				 		subTaskUniqueId = @subTaskUniqueId
				 
				 	update
				 		wip0
				 	set
				 		units = (case when wip0.units > wip1.units then wip0.units else wip1.units end),
				 		minDuration = (case when ((wip0.minDuration > 0) and (wip0.minDuration < wip1.minDuration)) then wip0.minDuration else wip1.minDuration end),
				 		maxDuration = (case when wip0.maxDuration > wip1.maxDuration then wip0.maxDuration else wip1.maxDuration end)
				 	from
				 		#wipControl wip0
				 			inner join
				 				(
				 					select
				 						resourceTypeId,
				 						sum(units) units,
				 						min(duration) minDuration,
				 						max(duration) maxDuration
				 					from
				 						#wipControl
				 					where
				 						wip = 1
				 					group by
				 						resourceTypeId
				 				) wip1
				 				on	wip1.resourceTypeId = wip0.resourceTypeId
				 	where
				 		wip = 0
				 
				 	set @wip = @wip + 1
				 
				 	--select @wip, * from #wipControl
				end
			else
				set @bLoop = 0
		end
				 
	close curTasks
	deallocate curTasks
				 
	insert into #maxResourceTypeUnitsDurationByDay
	(
		projectId,
		taskUniqueId,
		resourceTypeId,
		units,
		duration,
		calendarDay
	)
	select
		@previousProjectId,
		@previousTaskUniqueId,
		resourceTypeId,
		units,
		(duration + maxDuration) / 600.0,
		@previousStartDate
	from
		#wipControl
	where
		wip = 0 and
		units > 0
				
	if exists(select 1 from sysobjects where type = 'u' and name = 'LoadByDayByResourceType')
		drop table LoadByDayByResourceType
	--else
				
	--select
	--	mt.projectId,
	--	mt.taskUniqueId,
	--	mrtd.resourceTypeId,
	--	mrtd.units,
	--	(mrtd.duration / 600.0) duration,
	--	mrtd.calendarDay,
	--	mt.processType,
	--	mt.processLimit
	--into
	--	LoadByDayByResourceType
	--from
	--	(
	--		select distinct
	--			projectId,
	--			taskUniqueId,
	--			processType,
	--			processLimit
	--		from
	--			#movedTasks
	--	) mt
	--		inner join #maxResourceTypeUnitsDurationByDay mrtd
	--			on	mrtd.projectId = mt.projectId and
	--				mrtd.taskUniqueId = mt.taskUniqueId

	select distinct
		mt.projectId,
		mt.taskUniqueId,
		mrtd.resourceTypeId,
		mrtd.units,
		(mrtd.duration / 600.0) duration,
		mrtd.calendarDay,
		mt.processType,
		mt.processLimit
	into
		LoadByDayByResourceType
	from
		 #movedtasks mt
			inner join #maxResourceTypeUnitsDurationByDay mrtd
				on	mrtd.projectId = mt.projectId and
					mrtd.taskUniqueId = mt.taskUniqueId
			
	drop table #tasks
	drop table #resourceTypesByTask
	drop table #movedTasks
	drop table #wipControl
	drop table #maxResourceTypeUnitsDurationByDay

	set nocount off
end
