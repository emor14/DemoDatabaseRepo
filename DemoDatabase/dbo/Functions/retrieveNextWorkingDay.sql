CREATE function [dbo].[retrieveNextWorkingDay](@projectId int, @calendarUniqueId int, @startDateTime datetime, @offSet int, @duration int) returns
@target table
(
	targetDatetime datetime,
	days int,
	dayValues varchar(max)
)
as
begin
	declare
		@result datetime,
		@days int = 0,
		@dayValues varchar(max) = '',

		@dayOfWeek int,
		@Working bit = 0,
		@FromDateTime1 datetime,
		@ToDateTime1 datetime,
		@FromDateTime2 datetime,
		@ToDateTime2 datetime,
		@FromDateTime3 datetime,
		@ToDateTime3 datetime,

		@interval1 float,
		@interval2 float,
		@interval3 float,

		@diff int,

		@skipDay bit = 0,
		@firstIteration bit = 1,

		@_offSet int,
		@_duration int,
		@_remainingOffSet int = 0,

		@maxLoop int = 300,
		@_dayOfWeek int,

		@startOfProcess bit = (case when @duration > 0 then 1 else 0 end)

	set @result = @startDateTime
	set @_offSet = @offSet * 6
	set @_duration = @duration * 6
	set @_remainingOffSet = @_offSet

	while ((@firstIteration = 1) or (@_offSet > 0) or (@skipDay = 1)) and (@maxLoop > 0)
		begin
			set @maxLoop = @maxLoop - 1

			select
				@dayOfWeek = DayOfWeek,
				@working = (case when cwt.Working = 1 then 1 else 0 end),
				@fromDateTime1 = (case when cwt.FromTime1 is null then null else dateadd(SECOND, DATEDIFF(SECOND, cast(cwt.FromTime1 as date), cwt.FromTime1), cast(cast(@startDateTime as date) as datetime)) end),
				@toDateTime1 = (case when cwt.ToTime1 is null then null else dateadd(SECOND, DATEDIFF(SECOND, cast(cwt.ToTime1 as date), cwt.ToTime1), cast(cast(@startDateTime as date) as datetime)) end),
				@fromDateTime2 = (case when cwt.FromTime2 is null then null else dateadd(SECOND, DATEDIFF(SECOND, cast(cwt.FromTime2 as date), cwt.FromTime2), cast(cast(@startDateTime as date) as datetime)) end),
				@toDateTime2 = (case when cwt.ToTime2 is null then null else dateadd(SECOND, DATEDIFF(SECOND, cast(cwt.ToTime2 as date), cwt.ToTime2), cast(cast(@startDateTime as date) as datetime)) end),
				@fromDateTime3 = (case when cwt.FromTime3 is null then null else dateadd(SECOND, DATEDIFF(SECOND, cast(cwt.FromTime3 as date), cwt.FromTime3), cast(cast(@startDateTime as date) as datetime)) end),
				@toDateTime3 = (case when cwt.ToTime3 is null then null else dateadd(SECOND, DATEDIFF(SECOND, cast(cwt.ToTime3 as date), cwt.ToTime3), cast(cast(@startDateTime as date) as datetime)) end)
			from
				Calendar_Working_Times cwt
			where
				cwt.projectId = @projectId and
				cwt.calendarUniqueId = @calendarUniqueId and
				cwt.dayofWeek = datepart(w, @startDateTime)

			if IsNull(@Working, 0) = 1
				begin
					set @days = @days + 1

					set @skipDay = 0
					set  @_dayOfWeek = @dayOfWeek

					--
					--Interval 1
					--
					if @result < @FromDateTime1
						set @result = @FromDateTime1
					--else

					if (@result >= @FromDateTime1) and ((@firstIteration = 0) or (@result < @ToDateTime1))
						begin
							if @_offSet <= datediff(SECOND, @result, @toDateTime1)
								begin
									set @result = dateadd(SECOND, @_offSet, @result)
									set @_offSet = 0
								end
							else
								begin
									set @diff = datediff(SECOND, @result, @toDateTime1)
									set @result = @toDateTime1
									set @_offSet = @_offSet - @diff
								end
						end
					--else
					if (@startOfProcess = 1) and ((@result >= @ToDateTime1) or (datediff(SECOND, @result, @toDateTime1) < 60.0) and (datediff(SECOND, @result, @toDateTime1) < @_duration))
						if (@FromDateTime2 is null)
							set @skipDay = 1
						else
							if (@firstIteration = 1) and (@result > @ToDateTime1) and (@result < @FromDateTime2)
								set @result = @FromDateTime2
							--else
					--else

					--
					--Interval 2
					--
					if (@_offSet > 0) and (@FromDateTime2 is not null) and (@result < @FromDateTime2)
						set @result = @FromDateTime2
					--else

					if (@_offSet > 0) and (@FromDateTime2 is not null) and (@result >= @FromDateTime2) and ((@firstIteration = 0) or (@result < @ToDateTime2))
						begin
							if @_offSet <= datediff(SECOND, @result, @toDateTime2)
								begin
									set @result = dateadd(SECOND, @_offSet, @result)
									set @_offSet = 0
								end
							else
								begin
									set @diff = datediff(SECOND, @result, @toDateTime2)
									set @result = @toDateTime2
									set @_offSet = @_offSet - @diff
								end
						end
					--else
					if (@startOfProcess = 1) and ((@result >= @ToDateTime2) or (datediff(SECOND, @result, @toDateTime2) < 60.0) and (datediff(SECOND, @result, @toDateTime2) < (@_duration - @interval1)))
						if (@FromDateTime3 is null)
							set @skipDay = 1
						else
							if (@firstIteration = 1) and (@result > @ToDateTime2) and (@result < @FromDateTime3)
								set @result = @FromDateTime3
							--else
					--else

					--
					--Interval 3
					--
					if (@_offSet > 0) and (@FromDateTime3 is not null) and (@result < @FromDateTime3)
						set @result = @FromDateTime3
					--else

					if (@_offSet > 0) and (@FromDateTime3 is not null) and (@result >= @FromDateTime3) and ((@firstIteration = 0) or (@result < @ToDateTime3))
						begin
							if @_offSet <= datediff(SECOND, @result, @toDateTime3)
								begin
									set @result = dateadd(SECOND, @_offSet, @result)
									set @_offSet = 0
								end
							else
								begin
									set @diff = datediff(SECOND, @result, @toDateTime3)
									set @result = @toDateTime3
									set @_offSet = @_offSet - @diff
								end
						end
					--else
					if (@startOfProcess = 1) and ((@result >= @ToDateTime3) or (datediff(SECOND, @result, @toDateTime3) < 60.0) and (datediff(SECOND, @result, @toDateTime3) < (@_duration - @interval1 - @interval2)))
						set @skipDay = 1
					--else
				end
			--else

			set @dayValues =
			(
				case when @duration > 0
					then
						cast(@_dayOfWeek as varchar)
					else
						@dayValues +
						(
							(
								cast((@_remainingOffSet - @_offSet) as varchar) + ':' +
								(
									case when @days > 1
										then
											(IsNull(convert(varchar(19), @FromDateTime1, 121), '') + '|')
										else
											(convert(varchar(19), @startDateTime, 121) + '|')
									end
								) +
								convert(varchar(19), @result, 121)
							)
						) + ';'
				end
			)

			set @startDateTime = dateadd(day, 1, @startDateTime)
			set @_remainingOffSet = @_offSet
			set @firstIteration = 0
		end

	insert into @target values (@result, @days, @dayValues)

	return
end
