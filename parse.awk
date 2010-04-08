BEGIN {
    valid = 0

    waiting_ln = 0
    player_disconnected_ln = 0
    coach_disconnected_ln = 0

    left_score = 0
    right_score = 0
}
{
    if ($0 ~ /Waiting after end of match/) {
        waiting_ln = NR
    }
    else if ($0 ~ /A player disconnected/) {
        if (player_disconnected_ln == 0) {
            player_disconnected_ln = NR
        }
    }
    else if ($0 ~ /An online coach disconnected/) {
        if (coach_disconnected_ln == 0) {
            coach_disconnected_ln = NR
        }
    }
    else if ($0 ~ /Score:/) {
        left_score = $2
        right_score = $4
    }
}

END {
    if (player_disconnected_ln > waiting_ln && coach_disconnected_ln > waiting_ln) {
        valid = 1
    }

    print left_score, right_score, valid
}


