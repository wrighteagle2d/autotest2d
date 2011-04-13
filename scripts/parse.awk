BEGIN {
    valid = 0

    waiting_ln = -1
    player_disconnected_ln = -1
    coach_disconnected_ln = -1

    left_score = -1
    right_score = -1

    left_shoot_count = 0

    miss_count = 0
}

{
    if ($0 ~ /Waiting after end of match/) {
        waiting_ln = NR
    }
    else if ($0 ~ /A player disconnected/) {
        if (player_disconnected_ln <= 0) {
            player_disconnected_ln = NR
        }
    }
    else if ($0 ~ /An online coach disconnected/) {
        if (coach_disconnected_ln <= 0) {
            coach_disconnected_ln = NR
        }
    }
    else if ($0 ~ /Score:/) {
        left_score = $2
        right_score = $4
    }
    else if ($0 ~ /miss a turn_neck/) {
        miss_count += 1
    }
    else if ($0 ~ /: shoot/) {
        left_shoot_count += 1
    }
}

END {
    if (waiting_ln >= 0 && player_disconnected_ln > waiting_ln && coach_disconnected_ln > waiting_ln) {
        valid = 1
    }

    if (left_score >= 0 && right_score >= 0) {
        print left_score, right_score, left_shoot_count, valid, miss_count
    }
}

