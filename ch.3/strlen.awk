BEGIN {
    for ( i = 0; i < 1024; i++) {
        kilo = kilo " "
    }
    i = 0
    while(1) {
        printf "%dK ", ++i
        s = s kilo
    }
}