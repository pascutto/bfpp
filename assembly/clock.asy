main: {
    reset 1;                                // pos sur la premiere bande = 0
    incr #1;                                // incr les secondes					
    xor #1,sec;
    cond_jump nzflag,print;                 // verifier si secondes < 60
    sub #1,sec;
    mv #2,#1;
    right 1;
    jump incr_min;
}

incr_min: {
    incr #1;                                // incr les minutes
    xor #1,min;
    cond_jump nzflag,print;                 // verifier si minutes < 60
    sub #1,min;
    mv #2,#1;
    right 1;
    jump incr_hour;
}

incr_hour: {
    incr #1;                                // incr les heures
    xor #1,hour;
    cond_jump nzflag,print;                 // verifier si heures < 24
    sub #1,hour;
    mv #2,#1;
    right 1;
    jump incr_day;
}

incr_day: {
    right 1;
    mv #1,#2;                               // #2 = mois
    left 1;
    incr #1;                                // incr les jours
    right 2;
    or #2,0;                                // verifier si l'annee en cours est bisextile
    left 2;
    cond_jump zflag,incr_day_nonleap;
    jump incr_day_leap;
}

incr_day_nonleap: {
    xor #1,daynleap[#2];
    cond_jump nzflag,print;                 // verifier si jours < nb de jours dans mois
    right 1;
    mv #1,#2;                               // #2 = mois
    left 1;
    sub #1,daynleap[#2];
    mv #2,#1;
    right 1;
    jump incr_month;
}

incr_day_leap: {
    xor #1,dayleap[#2];
    cond_jump nzflag,print;                 // verifier si jours < nb de jours dans mois
    right 1;
    mv #1,#2;                               // #2 = mois
    left 1;
    sub #1,dayleag[#2];
    mv #2,#1;
    right 1;
    jump incr_month;
}

incr_month: {
    incr #1;                                // incr les mois
    xor #1,month;
    cond_jump nzflag,print;                 // verifier si mois < 12
    sub #1,month;
    mv #2,#1;
    right 1;
    jump incr_year;
}

incr_year: {
    incr #1;                                // incr les annees
    mod #1,400;
    cond_jump zflag,print_leap;
    mod #1,100;
    cond_jump zflag,print_nonleap;
    mod #1,4;
    cond_jump zflag,print_leap;
    jump print_nonleap;
}

print_nonleap: {
    right 2;
    mv 0,#2;
    left 2;
    jump print;
}

print_leap: {
    right 2;
    mv 1,#2;
    left 2;
    jump print;
}

print: {
    reset 1;
    jump wait_clock;
    						                // afficher
    jump main;
}

wait_clock: {
    cond_jump nclockflag,wait_clock;
    exit;
}

var: {
    sec: 60;
    min: 60;
    hour: 24;
    daynleap: [31; 28; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31]; 
    dayleap: [31; 29; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31];
    month: 12; 
}

// zflag - zero flag
// nzflag - non zero flag
// clockflag - clock input
// nclockflag - not (clock input)
