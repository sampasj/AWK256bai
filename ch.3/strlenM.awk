BEGIN {
    for ( i = 0; i < 1048576; i++) {   # 1048576 = 1024 * 1024
        mega = mega " "
    }
    i = 0
    while(1) {
        printf "%dM ", ++i
        s = s mega
    }
}