main: {
    reset;					// $pos = 0
    incr #;					// incr les secondes					
    xor #,sec;
    not $zflag;
    cond_jump $res,print;			// verifier si secondes < 60
    sub #,sec;
    mv $res,#;
    right;					
    incr #;					// incr les minutes
    xor #,min;
    not $zflag;
    cond_jump $res,print;			// verifier si minutes < 60
    sub #,min;
    mv $res,#;
    right;
    incr #;					// incr les heures
    xor #,hour;
    not $zflag;
    cond_jump $res,print;			// verifier si heures < 24
    sub #,hour;
    mv $res,#;
    right;
    right;
    mv #,$r0; 					// $r0 = mois
    left;
    incr #;					// incr les jours
    xor #,day[$r1][$r0];
    not $zflag;
    cond_jump $res,print;			// verifier si jours < nb de jours dans mois
    sub #,day[$r1][$r0];
    mv $res,#;
    right;
    incr #;					// incr les mois
    xor #,month;
    not $zflag;
    cond_jump $res,print;			// verifier si mois < 12
    sub #,month;
    mv $res,#;
    right;
    incr #;					// incr les annees
    mod #,400;
    cond_jump $zflag,print_leap;
    mod #,100;
    cond_jump $zflag,print_nonleap;
    mod #,4;
    cond_jump $zflag,print_leap;
    jump print_nonleap;
}

print_nonleap: {
    mv 1,$r1;
    jump print;
}

print_leap: {
    mv 1,$r1;
    jump print;
}

print: {
    reset;
    jump wait_clock;
    						// afficher
    jump main;
}

wait_clock: {
    not $clock;
    cond_jump $res,wait_clock;
    exit;
}

var: {
    sec: 60;
    min: 60;
    hour: 24;
    day: [[31; 28; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31]; [31; 29; 31; 30; 31; 30; 31; 31; 30; 31; 30; 31]];
    month: 12; 
}
