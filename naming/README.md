kakusu.dic の作成
```
cat 人名使用可能漢字.txt | nkf -Z | awk 'BEGIN{RS="";FS="\n"}{sub("画", "", $1); kakusu=$1; for (i=2; i<=NF; i++)print $i,kakusu}' > kakusu.dic
```
