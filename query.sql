WITH qualifiers AS (
  SELECT
    u.user_id AS user_id,
    u.handle_lc AS username,
    u.is_available AS is_available,
    u.is_deactivated AS is_deactivated,
    CASE WHEN EXISTS (SELECT 1 FROM tracks WHERE u.user_id = tracks.owner_id AND tracks.is_available AND NOT tracks.is_delete) THEN 1 ELSE 0 END AS has_uploaded,
    CASE WHEN EXISTS (SELECT 1 FROM tracks WHERE u.user_id = tracks.owner_id AND tracks.remix_of IS NOT NULL AND tracks.is_available AND NOT tracks.is_delete) THEN 1 ELSE 0 END AS has_made_remix,
    CASE WHEN EXISTS (SELECT 1 FROM plays WHERE u.user_id = plays.user_id) THEN 1 ELSE 0 END AS has_played,
    CASE WHEN EXISTS (SELECT 1 FROM user_balances WHERE u.user_id = user_balances.user_id AND (CAST(waudio AS NUMERIC) + CAST(associated_wallets_balance AS NUMERIC) + CAST(associated_sol_wallets_balance AS NUMERIC) > 100000000000)) THEN 1 ELSE 0 END AS has_tier,
    (SELECT COALESCE((CAST(waudio AS NUMERIC) + CAST(associated_wallets_balance AS NUMERIC) + CAST(associated_sol_wallets_balance AS NUMERIC)) / 1000000000000000000, 0) 
     FROM user_balances 
     WHERE u.user_id = user_balances.user_id
    ) AS total_balance,
    CASE WHEN EXISTS (
        SELECT 1 
        FROM user_balances 
        WHERE u.user_id = user_balances.user_id 
        AND ((CAST(waudio AS NUMERIC) + CAST(associated_wallets_balance AS NUMERIC) + CAST(associated_sol_wallets_balance AS NUMERIC)) / 1000000000000000000 >= 10)
    ) THEN 1 ELSE 0 END AS has_bronze_tier,
    CASE WHEN EXISTS (
        SELECT 1 
        FROM user_balances 
        WHERE u.user_id = user_balances.user_id 
        AND ((CAST(waudio AS NUMERIC) + CAST(associated_wallets_balance AS NUMERIC) + CAST(associated_sol_wallets_balance AS NUMERIC)) / 1000000000000000000 >= 100)
    ) THEN 1 ELSE 0 END AS has_silver_tier,
    CASE WHEN EXISTS (
        SELECT 1 
        FROM user_balances 
        WHERE u.user_id = user_balances.user_id 
        AND ((CAST(waudio AS NUMERIC) + CAST(associated_wallets_balance AS NUMERIC) + CAST(associated_sol_wallets_balance AS NUMERIC)) / 1000000000000000000 >= 1000)
    ) THEN 1 ELSE 0 END AS has_gold_tier,
    CASE WHEN EXISTS (
        SELECT 1 
        FROM user_balances 
        WHERE u.user_id = user_balances.user_id 
        AND ((CAST(waudio AS NUMERIC) + CAST(associated_wallets_balance AS NUMERIC) + CAST(associated_sol_wallets_balance AS NUMERIC)) / 1000000000000000000 >= 10000)
    ) THEN 1 ELSE 0 END AS has_plat_tier,
    CASE WHEN u.is_verified AND EXISTS (SELECT 1 FROM tracks WHERE tracks.owner_id = u.user_id AND tracks.is_available AND NOT tracks.is_delete) THEN 1 ELSE 0 END AS is_verified_artist,
    CASE WHEN EXISTS (SELECT 1 FROM tracks WHERE u.user_id = tracks.owner_id AND tracks.stream_conditions ? 'usdc_purchases' AND tracks.is_available AND NOT tracks.is_delete) THEN 1 ELSE 0 END AS has_premium_track,
    CASE WHEN EXISTS (SELECT 1 FROM tracks WHERE u.user_id = tracks.owner_id AND tracks.is_available AND NOT tracks.is_delete) THEN (
        SELECT COALESCE(SUM(ap.count), 0)
        FROM tracks t
        LEFT JOIN aggregate_plays ap ON t.track_id = ap.play_item_id
        WHERE t.owner_id = u.user_id AND t.is_available AND NOT t.is_delete
    )
    ELSE 0 END AS total_stream_count,
    (
        SELECT COALESCE(SUM(agg."repost_count"), 0)
        FROM "public"."tracks" t
        LEFT JOIN "public"."aggregate_track" agg
        ON t.track_id = agg.track_id
        WHERE t.owner_id = u.user_id AND t.is_available AND NOT t.is_delete
    ) AS total_reposts,
    (
        SELECT COALESCE(SUM(agg."save_count"), 0)
        FROM "public"."tracks" t
        LEFT JOIN "public"."aggregate_track" agg
        ON t.track_id = agg.track_id
        WHERE t.owner_id = u.user_id AND t.is_available AND NOT t.is_delete
    ) AS total_favorites,
    (
        SELECT COUNT(*)
        FROM usdc_purchases up
        WHERE up.seller_user_id = u.user_id
    ) AS total_sells,
    (
        SELECT COUNT(*)
        FROM usdc_purchases up
        WHERE up.buyer_user_id = u.user_id
    ) AS total_buys,
    (
        SELECT COALESCE(SUM(amount::numeric / 1000000), 0)
        FROM usdc_purchases up
        WHERE up.seller_user_id = u.user_id
    ) AS total_revenue,
    (
        SELECT COALESCE(follower_count, 0)
        FROM aggregate_user au
        WHERE au.user_id = u.user_id
    ) AS total_followers,
    CASE WHEN EXISTS (SELECT 1 FROM tracks WHERE u.user_id = tracks.owner_id) THEN (
        CASE WHEN (
            SELECT COALESCE(SUM(ap.count), 0)
            FROM tracks t
            LEFT JOIN aggregate_plays ap ON t.track_id = ap.play_item_id
            WHERE t.owner_id = u.user_id AND t.is_available AND NOT t.is_delete
        ) >= 1000 THEN 1 ELSE 0 END
    )
    ELSE 0 END AS has_1000_streams,
    CASE WHEN EXISTS (SELECT 1 FROM tracks WHERE u.user_id = tracks.owner_id) THEN (
        CASE WHEN (
            SELECT COALESCE(SUM(ap.count), 0)
            FROM tracks t
            LEFT JOIN aggregate_plays ap ON t.track_id = ap.play_item_id
            WHERE t.owner_id = u.user_id AND t.is_available AND NOT t.is_delete
        ) >= 10000 THEN 1 ELSE 0 END
    )
    ELSE 0 END AS has_10000_streams
  FROM users u
)
SELECT *
FROM (
  SELECT
    q.*,
    (
        q.has_made_remix +
        q.has_uploaded +
        q.has_played +
        q.has_tier +
        q.has_bronze_tier +
        q.has_silver_tier +
        q.has_gold_tier +
        q.has_plat_tier +
        q.is_verified_artist +
        q.has_premium_track +
        q.has_1000_streams +
        q.has_10000_streams
    ) AS total
  FROM qualifiers q
) sq
WHERE total > 0 and has_uploaded = 1 and is_available and not is_deactivated
ORDER BY total DESC, user_id ASC;
