CREATE TABLE #Codesets (
  codeset_id int NOT NULL,
  concept_id bigint NOT NULL
)
;

INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 1 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (80502)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (80502)
  and c.invalid_reason is null

) I
) C UNION ALL 
SELECT 10 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (40222444,21604169)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (40222444,21604169)
  and c.invalid_reason is null

) I
) C UNION ALL 
SELECT 13 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (75910,4264281,443392)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (75910,4264281,443392)
  and c.invalid_reason is null

) I
) C UNION ALL 
SELECT 15 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (1524674,1511646,1521987,1511251,1513103,44506794,21604156,21604151,21602783,1501781,21602625,21602626,21604155,45893276,1516800,21604154,1512480,21604152,21604160,1557272)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (1524674,1511646,1521987,1511251,1513103,44506794,21604156,21604151,21602783,1501781,21602625,21602626,21604155,1516800,21604154,1512480,21604152,1557272)
  and c.invalid_reason is null

) I
) C UNION ALL 
SELECT 16 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (435093,77129,4170742,441974,441422,4230399)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (435093,77129,4170742,441974,441422,4230399)
  and c.invalid_reason is null

) I
) C
;

 select de.* , row_number() over (PARTITION BY de.person_id ORDER BY de.drug_exposure_start_date, de.drug_exposure_id) as ordinal
  into #CodeSetData_10
  FROM @cdm_database_schema.DRUG_EXPOSURE de
  JOIN #Codesets codesets on ((de.drug_concept_id = codesets.concept_id and codesets.codeset_id = 10));


  SELECT co.* 
  into #CodeSetData_1
  FROM @cdm_database_schema.CONDITION_OCCURRENCE co
  JOIN #Codesets codesets on ((co.condition_concept_id = codesets.concept_id and codesets.codeset_id = 1));

  select de.* 
  into #CodeSetData_15
  FROM @cdm_database_schema.DRUG_EXPOSURE de
  JOIN #Codesets codesets on ((de.drug_concept_id = codesets.concept_id and codesets.codeset_id = 15));

  SELECT co.* 
  into #CodeSetData_13
  FROM @cdm_database_schema.CONDITION_OCCURRENCE co
  JOIN #Codesets codesets on ((co.condition_concept_id = codesets.concept_id and codesets.codeset_id = 13));


  SELECT co.* 
  into #CodeSetData_16
  FROM @cdm_database_schema.CONDITION_OCCURRENCE co
  JOIN #Codesets codesets on ((co.condition_concept_id = codesets.concept_id and codesets.codeset_id = 16));


--------------------------------------------------------- denosumab extra code
UPDATE #CodeSetData_10
SET drug_exposure_end_date = 
case 
when drug_source_value IN ('052300041') THEN  dateadd(day, quantity*180-1, drug_exposure_start_date)
ELSE dateadd(day, quantity*30-1, drug_exposure_start_date)
END;
--------------------------------------------------------- 

with primary_events (event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id) as
(
-- Begin Primary Events
select P.ordinal as event_id, P.person_id, P.start_date, P.end_date, op_start_date, op_end_date, cast(P.visit_occurrence_id as bigint) as visit_occurrence_id
FROM
(
  select E.person_id, E.start_date, E.end_date,
         row_number() OVER (PARTITION BY E.person_id ORDER BY E.sort_date ASC) ordinal,
         OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date, cast(E.visit_occurrence_id as bigint) as visit_occurrence_id
  FROM 
  (
  -- Begin Drug Exposure Criteria
select C.person_id, C.drug_exposure_id as event_id, C.drug_exposure_start_date as start_date,
       COALESCE(C.DRUG_EXPOSURE_END_DATE, DATEADD(day,C.DAYS_SUPPLY,DRUG_EXPOSURE_START_DATE), DATEADD(day,1,C.DRUG_EXPOSURE_START_DATE)) as end_date,
       C.visit_occurrence_id,C.drug_exposure_start_date as sort_date
from #CodeSetData_10 C
JOIN @cdm_database_schema.PERSON P on C.person_id = P.person_id
WHERE YEAR(C.drug_exposure_start_date) - P.year_of_birth >= 50
AND C.ordinal = 1
-- End Drug Exposure Criteria

  ) E
	JOIN @cdm_database_schema.observation_period OP on E.person_id = OP.person_id and E.start_date >=  OP.observation_period_start_date and E.start_date <= op.observation_period_end_date
  WHERE DATEADD(day,365,OP.OBSERVATION_PERIOD_START_DATE) <= E.START_DATE AND DATEADD(day,0,E.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE
) P
WHERE P.ordinal = 1
-- End Primary Events

)
SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id
INTO #qualified_events
FROM 
(
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal, cast(pe.visit_occurrence_id as bigint) as visit_occurrence_id
  FROM primary_events pe
  
) QE

;

--- Inclusion Rule Inserts

select 0 as inclusion_rule_id, person_id, event_id
INTO #Inclusion_0
FROM 
(
  select pe.person_id, pe.event_id
  FROM #qualified_events pe
  
JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id 
  FROM #qualified_events E
  INNER JOIN
  (
    -- Begin Correlated Criteria
select 0 as index_id, cc.person_id, cc.event_id
from (SELECT p.person_id, p.event_id 
FROM #qualified_events P
JOIN (
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date,
  C.visit_occurrence_id, C.condition_start_date as sort_date
FROM #CodeSetData_1 C


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.START_DATE) ) cc 
GROUP BY cc.person_id, cc.event_id
HAVING COUNT(cc.event_id) >= 1
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

select 1 as inclusion_rule_id, person_id, event_id
INTO #Inclusion_1
FROM 
(
  select pe.person_id, pe.event_id
  FROM #qualified_events pe
  
JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id 
  FROM #qualified_events E
  INNER JOIN
  (
    -- Begin Correlated Criteria
select 0 as index_id, p.person_id, p.event_id
from #qualified_events p
LEFT JOIN (
SELECT p.person_id, p.event_id 
FROM #qualified_events P
JOIN (
  -- Begin Drug Exposure Criteria
select C.person_id, C.drug_exposure_id as event_id, C.drug_exposure_start_date as start_date,
       COALESCE(C.DRUG_EXPOSURE_END_DATE, DATEADD(day,C.DAYS_SUPPLY,DRUG_EXPOSURE_START_DATE), DATEADD(day,1,C.DRUG_EXPOSURE_START_DATE)) as end_date,
       C.visit_occurrence_id,C.drug_exposure_start_date as sort_date
from #CodeSetData_15 C


-- End Drug Exposure Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.START_DATE) ) cc on p.person_id = cc.person_id and p.event_id = cc.event_id
GROUP BY p.person_id, p.event_id
HAVING COUNT(cc.event_id) = 0
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

select 2 as inclusion_rule_id, person_id, event_id
INTO #Inclusion_2
FROM 
(
  select pe.person_id, pe.event_id
  FROM #qualified_events pe
  
JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id 
  FROM #qualified_events E
  INNER JOIN
  (
    -- Begin Correlated Criteria
select 0 as index_id, p.person_id, p.event_id
from #qualified_events p
LEFT JOIN (
SELECT p.person_id, p.event_id 
FROM #qualified_events P
JOIN (
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date,
  C.visit_occurrence_id, C.condition_start_date as sort_date
FROM #CodeSetData_13 C


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.START_DATE) ) cc on p.person_id = cc.person_id and p.event_id = cc.event_id
GROUP BY p.person_id, p.event_id
HAVING COUNT(cc.event_id) = 0
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

select 3 as inclusion_rule_id, person_id, event_id
INTO #Inclusion_3
FROM 
(
  select pe.person_id, pe.event_id
  FROM #qualified_events pe
  
JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id 
  FROM #qualified_events E
  INNER JOIN
  (
    -- Begin Correlated Criteria
select 0 as index_id, cc.person_id, cc.event_id
from (SELECT p.person_id, p.event_id 
FROM #qualified_events P
JOIN (
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date,
  C.visit_occurrence_id, C.condition_start_date as sort_date
FROM #CodeSetData_16 C


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.START_DATE) ) cc 
GROUP BY cc.person_id, cc.event_id
HAVING COUNT(cc.event_id) >= 1
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

SELECT inclusion_rule_id, person_id, event_id
INTO #inclusion_events
FROM (select inclusion_rule_id, person_id, event_id from #Inclusion_0
UNION ALL
select inclusion_rule_id, person_id, event_id from #Inclusion_1
UNION ALL
select inclusion_rule_id, person_id, event_id from #Inclusion_2
UNION ALL
select inclusion_rule_id, person_id, event_id from #Inclusion_3) I;
TRUNCATE TABLE #Inclusion_0;
DROP TABLE #Inclusion_0;

TRUNCATE TABLE #Inclusion_1;
DROP TABLE #Inclusion_1;

TRUNCATE TABLE #Inclusion_2;
DROP TABLE #Inclusion_2;

TRUNCATE TABLE #Inclusion_3;
DROP TABLE #Inclusion_3;


with cteIncludedEvents(event_id, person_id, start_date, end_date, op_start_date, op_end_date, ordinal) as
(
  SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, row_number() over (partition by person_id order by start_date ASC) as ordinal
  from
  (
    select Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date, SUM(coalesce(POWER(cast(2 as bigint), I.inclusion_rule_id), 0)) as inclusion_rule_mask
    from #qualified_events Q
    LEFT JOIN #inclusion_events I on I.person_id = Q.person_id and I.event_id = Q.event_id
    GROUP BY Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date
  ) MG -- matching groups
{4 != 0}?{
  -- the matching group with all bits set ( POWER(2,# of inclusion rules) - 1 = inclusion_rule_mask
  WHERE (MG.inclusion_rule_mask = POWER(cast(2 as bigint),4)-1)
}
)
select event_id, person_id, start_date, end_date, op_start_date, op_end_date
into #included_events
FROM cteIncludedEvents Results
WHERE Results.ordinal = 1
;

-- custom era strategy

with ctePersons(person_id) as (
	select distinct person_id from #included_events
)

select person_id, drug_exposure_start_date, drug_exposure_end_date
INTO #drugTarget
FROM (
	select de.PERSON_ID, DRUG_EXPOSURE_START_DATE, DRUG_EXPOSURE_END_DATE 
	FROM #CodeSetData_10 de
	JOIN ctePersons p on de.person_id = p.person_id

	UNION ALL

	select de.PERSON_ID, DRUG_EXPOSURE_START_DATE, DRUG_EXPOSURE_END_DATE 
	FROM #CodeSetData_10 de
	JOIN ctePersons p on de.person_id = p.person_id
) E
;

select et.event_id, et.person_id, ERAS.era_end_date as end_date
INTO #strategy_ends
from #included_events et
JOIN 
(
  select ENDS.person_id, min(drug_exposure_start_date) as era_start_date, DATEADD(day,0, ENDS.era_end_date) as era_end_date
  from
  (
    select de.person_id, de.drug_exposure_start_date, MIN(e.END_DATE) as era_end_date
    FROM #drugTarget DE
    JOIN 
    (
      --cteEndDates
      select PERSON_ID, DATEADD(day,-1 * 180,EVENT_DATE) as END_DATE -- unpad the end date by 180
      FROM
      (
				select PERSON_ID, EVENT_DATE, EVENT_TYPE, 
				MAX(START_ORDINAL) OVER (PARTITION BY PERSON_ID ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal,
				ROW_NUMBER() OVER (PARTITION BY PERSON_ID ORDER BY EVENT_DATE, EVENT_TYPE) AS OVERALL_ORD -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
				from
				(
					-- select the start dates, assigning a row number to each
					Select PERSON_ID, DRUG_EXPOSURE_START_DATE AS EVENT_DATE, 0 as EVENT_TYPE, ROW_NUMBER() OVER (PARTITION BY PERSON_ID ORDER BY DRUG_EXPOSURE_START_DATE) as START_ORDINAL
					from #drugTarget D

					UNION ALL

					-- add the end dates with NULL as the row number, padding the end dates by 180 to allow a grace period for overlapping ranges.
					select PERSON_ID, DATEADD(day,180,DRUG_EXPOSURE_END_DATE), 1 as EVENT_TYPE, NULL
					FROM #drugTarget D
				) RAWDATA
      ) E
      WHERE 2 * E.START_ORDINAL - E.OVERALL_ORD = 0
    ) E on DE.PERSON_ID = E.PERSON_ID and E.END_DATE >= DE.DRUG_EXPOSURE_START_DATE
    GROUP BY de.person_id, de.drug_exposure_start_date
  ) ENDS
  GROUP BY ENDS.person_id, ENDS.era_end_date
) ERAS on ERAS.person_id = et.person_id 
WHERE et.start_date between ERAS.era_start_date and ERAS.era_end_date;

TRUNCATE TABLE #drugTarget;
DROP TABLE #drugTarget;


-- generate cohort periods into #final_cohort
with cohort_ends (event_id, person_id, end_date) as
(
	-- cohort exit dates
  -- By default, cohort exit at the event's op end date
select event_id, person_id, op_end_date as end_date from #included_events
UNION ALL
-- End Date Strategy
SELECT event_id, person_id, end_date from #strategy_ends

UNION ALL
-- Censor Events
select i.event_id, i.person_id, MIN(c.start_date) as end_date
FROM #included_events i
JOIN
(
-- Begin Drug Exposure Criteria
select C.person_id, C.drug_exposure_id as event_id, C.drug_exposure_start_date as start_date,
       COALESCE(C.DRUG_EXPOSURE_END_DATE, DATEADD(day,C.DAYS_SUPPLY,DRUG_EXPOSURE_START_DATE), DATEADD(day,1,C.DRUG_EXPOSURE_START_DATE)) as end_date,
       C.visit_occurrence_id,C.drug_exposure_start_date as sort_date
from #CodeSetData_15 C


-- End Drug Exposure Criteria

) C on C.person_id = I.person_id and C.start_date >= I.start_date and C.START_DATE <= I.op_end_date
GROUP BY i.event_id, i.person_id


),
first_ends (person_id, start_date, end_date) as
(
	select F.person_id, F.start_date, F.end_date
	FROM (
	  select I.event_id, I.person_id, I.start_date, E.end_date, row_number() over (partition by I.person_id, I.event_id order by E.end_date) as ordinal 
	  from #included_events I
	  join cohort_ends E on I.event_id = E.event_id and I.person_id = E.person_id and E.end_date >= I.start_date
	) F
	WHERE F.ordinal = 1
)
select person_id, start_date, end_date
INTO #cohort_rows
from first_ends;

with cteEndDates (person_id, end_date) AS -- the magic
(	
	SELECT
		person_id
		, DATEADD(day,-1 * 0, event_date)  as end_date
	FROM
	(
		SELECT
			person_id
			, event_date
			, event_type
			, MAX(start_ordinal) OVER (PARTITION BY person_id ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal 
			, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY event_date, event_type) AS overall_ord
		FROM
		(
			SELECT
				person_id
				, start_date AS event_date
				, -1 AS event_type
				, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date) AS start_ordinal
			FROM #cohort_rows
		
			UNION ALL
		

			SELECT
				person_id
				, DATEADD(day,0,end_date) as end_date
				, 1 AS event_type
				, NULL
			FROM #cohort_rows
		) RAWDATA
	) e
	WHERE (2 * e.start_ordinal) - e.overall_ord = 0
),
cteEnds (person_id, start_date, end_date) AS
(
	SELECT
		 c.person_id
		, c.start_date
		, MIN(e.end_date) AS end_date
	FROM #cohort_rows c
	JOIN cteEndDates e ON c.person_id = e.person_id AND e.end_date >= c.start_date
	GROUP BY c.person_id, c.start_date
)
select person_id, min(start_date) as start_date, end_date
into #final_cohort
from cteEnds
group by person_id, end_date
;

DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select @target_cohort_id as cohort_definition_id, person_id, start_date, end_date 
FROM #final_cohort CO
;


TRUNCATE TABLE #strategy_ends;
DROP TABLE #strategy_ends;


TRUNCATE TABLE #cohort_rows;
DROP TABLE #cohort_rows;

TRUNCATE TABLE #final_cohort;
DROP TABLE #final_cohort;

TRUNCATE TABLE #inclusion_events;
DROP TABLE #inclusion_events;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;

TRUNCATE TABLE #CodeSetData_1;
DROP TABLE #CodeSetData_1;

TRUNCATE TABLE #CodeSetData_10;
DROP TABLE #CodeSetData_10;

TRUNCATE TABLE #CodeSetData_13;
DROP TABLE #CodeSetData_13;

TRUNCATE TABLE #CodeSetData_15;
DROP TABLE #CodeSetData_15;

TRUNCATE TABLE #CodeSetData_16;
DROP TABLE #CodeSetData_16;