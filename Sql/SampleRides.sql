DROP TABLE IF EXISTS taxi.samplerides;

-- count, sum
SELECT tripid, taxiid, tripstart, tripend, tripseconds, tripmiles, fare, tips, tolls, extracharges, triptotal, rec_updated
	INTO taxi.samplerides	
	FROM taxi.taxirides
	WHERE taxiid = '908ab4f3095c73d38a3a732e141603ec919d9e6e21528ea279ee9195d684a8d4b0c17531c3d2e2baccf276cf84de412cd6d56409b9600dee6e7260c8f022a780'
	ORDER BY tripstart
	LIMIT 1000	
	;

SELECT shiftid
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
		SELECT prev_tripend
				, tripstart
				, tripend
				, gapminutes
				, SUM(CASE WHEN gapminutes >= 60 THEN 1 ELSE 0 END) OVER (ORDER BY tripstart) AS shiftid
				, tripseconds
				, tripmiles
				, fare
				, tips
				, tolls
				, extracharges
				, triptotal
				, rec_updated
		FROM (
			SELECT prev_tripend
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
					SELECT tripid, taxiid
							, tripstart
							, COALESCE(LAG(tripend, 1) OVER (ORDER BY tripstart),'1000-01-01') prev_tripend
							, tripend		
							, tripseconds
							, tripmiles
							, fare
							, tips
							, tolls
							, extracharges
							, triptotal
							, rec_updated
						FROM taxi.samplerides	
						ORDER BY tripstart
				) as a
			) as a
		) as a
	GROUP BY shiftid
	ORDER BY shiftid
	;

select * from taxi.shiftmodel where taxiid = '908ab4f3095c73d38a3a732e141603ec919d9e6e21528ea279ee9195d684a8d4b0c17531c3d2e2baccf276cf84de412cd6d56409b9600dee6e7260c8f022a780' order by shiftstart


