-- MODEL UPDATE
WITH RECURSIVE new_modelentries
AS (
SELECT taxiid
		, MIN(tripstart) as shiftstart
		, MAX(tripend) as shiftend
		, EXTRACT(EPOCH FROM (MAX(tripend) - MIN(tripstart))) / 60 as shiftminutes
		, COUNT(*) as ridecount
		, SUM(tripseconds) as sum_tripseconds
		, SUM(tripmiles) as sum_tripmiles
		, SUM(fare) as sum_fare
		, SUM(tips) as sum_tips
		, SUM(tolls) as sum_tolls
		, SUM(extracharges) as sum_extracharges
		, SUM(triptotal) as sum_triptotal
		, MAX(rec_updated) as max_rec_updated
	FROM (
		SELECT taxiid
				, prev_tripend
				, tripstart
				, tripend
				, gapminutes
				, SUM(CASE WHEN gapminutes >= 60 THEN 1 ELSE 0 END) OVER (ORDER BY taxiid, tripstart) AS shiftid
				, tripseconds
				, tripmiles
				, fare
				, tips
				, tolls
				, extracharges
				, triptotal
				, rec_updated
		FROM (
			SELECT taxiid
					, prev_tripend
					, tripstart
					, tripend
					, EXTRACT(EPOCH FROM (tripstart - prev_tripend)) / 60 as gapminutes
					, tripseconds
					, tripmiles
					, fare
					, tips
					, tolls
					, extracharges
					, triptotal
					, rec_updated
				FROM (
					SELECT taxiid
							, tripstart
							, COALESCE(LAG(tripend, 1) OVER (ORDER BY taxiid, tripstart),'1000-01-01') prev_tripend
							, tripend		
							, tripseconds
							, tripmiles
							, fare
							, tips
							, tolls
							, extracharges
							, triptotal
							, rec_updated
						FROM taxi.taxirides							
						WHERE taxiid = '908ab4f3095c73d38a3a732e141603ec919d9e6e21528ea279ee9195d684a8d4b0c17531c3d2e2baccf276cf84de412cd6d56409b9600dee6e7260c8f022a780'
				) as a
			) as a
		) as a
	GROUP BY taxiid, shiftid
),
existing_modelentries as 
(
	SELECT shiftmodelid
		, taxiid
		, shiftstart
		, shiftend
		, shiftminutes
		, ridecount
		, sum_tripseconds
		, sum_tripmiles
		, sum_fare
		, sum_tips
		, sum_tolls
		, sum_extracharges
		, sum_triptotal
		, max_rec_updated
	FROM taxi.shiftmodel 
	WHERE taxiid = '908ab4f3095c73d38a3a732e141603ec919d9e6e21528ea279ee9195d684a8d4b0c17531c3d2e2baccf276cf84de412cd6d56409b9600dee6e7260c8f022a780'
),
existing_modelentries_minute
as 
(
	SELECT taxiid
		, shiftstart
		, shiftend
		, shiftstart AS shiftminutegen
		, shiftminutes
		/*, CASE WHEN shiftminutes > 0 THEN ridecount / shiftminutes ELSE ridecount END as ridecount
		, CASE WHEN sum_tripseconds / shiftminutes as sum_tripseconds
		, sum_tripmiles  / shiftminutes as sum_tripmiles
		, sum_fare / shiftminutes as sum_fare
		, sum_tips / shiftminutes as sum_tips
		, sum_tolls / shiftminutes as sum_tolls
		, sum_extracharges / shiftminutes as sum_extracharges
		, sum_triptotal / shiftminutes as sum_triptotal
		, max_rec_updated */
	FROM existing_modelentries
	UNION ALL
    SELECT
        r.taxiid
		, r.shiftstart
		, r.shiftend
		, r.shiftminutegen + INTERVAL '15 minutes' AS shiftminutegen
		, r.shiftminutes
		/*, r.ridecount
		, r.sum_tripseconds
		, r.sum_tripmiles
		, r.sum_fare
		, r.sum_tips
		, r.sum_tolls
		, r.sum_extracharges
		, r.sum_triptotal
		, r.max_rec_updated*/
    FROM existing_modelentries_minute r
		JOIN existing_modelentries m 
			ON r.taxiid = m.taxiid AND r.shiftstart = m.shiftstart
	WHERE r.shiftminutegen < r.shiftend
),
new_modelentries_minute
as 
(
	SELECT taxiid
		, shiftstart
		, shiftend
		, shiftstart AS shiftminutegen
		, shiftminutes
		/*, CASE WHEN shiftminutes > 0 THEN ridecount / shiftminutes ELSE ridecount END as ridecount
		, CASE WHEN sum_tripseconds / shiftminutes as sum_tripseconds
		, sum_tripmiles  / shiftminutes as sum_tripmiles
		, sum_fare / shiftminutes as sum_fare
		, sum_tips / shiftminutes as sum_tips
		, sum_tolls / shiftminutes as sum_tolls
		, sum_extracharges / shiftminutes as sum_extracharges
		, sum_triptotal / shiftminutes as sum_triptotal
		, max_rec_updated */
	FROM new_modelentries
	UNION ALL
    SELECT
        r.taxiid
		, r.shiftstart
		, r.shiftend
		, r.shiftminutegen + INTERVAL '15 minutes' AS shiftminutegen
		, r.shiftminutes
		/*, r.ridecount
		, r.sum_tripseconds
		, r.sum_tripmiles
		, r.sum_fare
		, r.sum_tips
		, r.sum_tolls
		, r.sum_extracharges
		, r.sum_triptotal
		, r.max_rec_updated*/
    FROM new_modelentries_minute r
		JOIN new_modelentries m 
			ON r.taxiid = m.taxiid AND r.shiftstart = m.shiftstart
	WHERE r.shiftminutegen < r.shiftend
)

SELECT * 
	from new_modelentries_minute
	order by taxiid, shiftminutegen
	
