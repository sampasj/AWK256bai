#
#  naming.awk - 姓名最適化スクリプト
#
#  Copyright (C) 1993 by SASAKI Takeshi
#
#  占い協力： keiz
#
#  説明
#    姓名の画数から運勢を判定し，より運のよい画数の文字を提案する．
#
#    データベースファイル kakusu.dic をカレントディレクト
 #    リに作成する．文字の画数はこのファイルから得る．与え
#    られた文字が kakusu.dic にない場合は、画数を要求して
#    くるので答えること．以後，その文字は kakusu.dic に登
#    録され，同じ文字について二度尋ねることはない．
#

BEGIN {
	if (ARGC != 3) {
		print "usage: jgawk -f seimei.awk <姓> <名>" > "/dev/stderr"
		exit(1)
	}

	kakudic = "kakusu.dic";
	untab = "point.tab";

	sei = ARGV[1]; mei = ARGV[2];
	simei = sei mei;
	slen = length(sei); mlen = length(mei);
	len = slen + mlen;
	ARGV[1] = ARGV[2] = ""

	make_map();
	read_point();
	read_kakudic();

	if (getkakusu(simei, kaku, len)) {
		addkakusu(simei, kaku, len);
	}
	print "";

	printf "あなたの名前は\t";
	for (i = 1; i <= len; i++)
		printf "%s ", substr(simei, i, 1);
	print "";
	printf "\t画数は\t";
	for (i = 1; i <= len; i++)
		printf "%2d ", kaku[i];
	print "";
	
	calc_all();

	printf "\nどの運勢をチューンしますか？(1-5): "; getline k;
	print "";
	if (k == 1)      tuneup(ten, ten_map);
	else if (k == 2) tuneup(ti,  ti_map);
	else if (k == 3) tuneup(jin, jin_map);
	else if (k == 4) tuneup(gai, gai_map);
	else if (k == 5) tuneup(sou, sou_map);
}

function read_kakudic()
{
	while (getline < kakudic) {
		kaku_tab[$2] = kaku_tab[$2] $1;
	}
}

function read_point(	i)
{
	while (getline < untab) {
		for (i = 2; i <= NF; i++) {
			point[$i] = $1;
			if ($i > kaku_max) {
				kaku_max = $i;
			}
		}
	}
}

function getkakusu(s, k, n,		i, j, c, r, rr)
{
	r = 0;
	for (j = 1; j <= n; j++) {
		c = substr(s, j, 1);
		rr = 1;
		for (i in kaku_tab) {
			if (kaku_tab[i] ~ c) {
# jgawk 2.15.2+1.0 is buggy?
#			if (jindex(kaku_tab[i], c)) {
				k[j] = i; rr = 0;
				break;
			}
		}
		r = r || rr;
	}
	return r;
}

function addkakusu(s, k, n,		i)
{
	for (i = 1; i <= n; i++) {
		if (k[i] == 0) {
			printf("「%s」の画数を教えてください: ", substr(s, i, 1));
			getline k[i];
			print substr(s, i, 1), k[i] >>kakudic;
		}
	}
}

function make_map(		i)
{
	for (i = 1; i <= slen; i++) {
		ten_map[i] = sou_map[i] = gai_map[i] = 1; 
	}
	for (i = 1; i <= mlen; i++) {
		ti_map[slen + i] = sou_map[slen + i] = gai_map[slen + i] = 1;
	}
	jin_map[slen] = jin_map[slen + 1] = 1;
	if (slen > 1) delete gai_map[slen];
	if (mlen > 1) delete gai_map[slen + 1];
}

function calc_all()
{
	ten = calc_point(ten_map);
	ti  = calc_point(ti_map);
	jin = calc_point(jin_map);
	gai = calc_point(gai_map);
	sou = calc_point(sou_map);
	printf("1.天運: %2d画%4d点\t", ten, point[ten] * 100);
	printf("2.地運: %2d画%4d点\n", ti, point[ti] * 100);
	printf("3.人運: %2d画%4d点\t", jin, point[jin] * 100);
	printf("4.外運: %2d画%4d点\t", gai, point[gai] * 100);
	printf("5.総運: %2d画%4d点\n", sou, point[sou] * 100);
}

function calc_point(map,		i, n)
{
	n = 0;
	for (i in map) n += kaku[i];
	return n;
}

function tuneup(un, map,		i, j, n, kouho, kaku_kouho, point_max, new)
{
	point_max = point[un]; j = 0;
	for (i = 1; i < kaku_max; i++) {
		if (point[i] > point_max) {
			kaku_kouho[1] = i; j = 2; point_max = point[i];
		} else if (point[i] == point_max) {
			kaku_kouho[j++] = i;
		}
	}
	if (point_max == point[un]) {
		print "これ以上よくなりません";
		return -1;
	}
	# どの文字を増やす?
	for (n = len; n >= 1; n--) if (n in map) break; 
	for (i = 1; i < j &&  0 > kaku[n] + kaku_kouho[i] - un; i++);
	kaku[n] += kaku_kouho[i] - un;

	printf "氏名の%d番目を%d画にチューンします\n",n,kaku[n];
	print "";

	if("" != (kouho = kaku_tab[kaku[n]])) {
		new = ""
		for (i = 1; i <= length(kouho); i++) {
			new = substr(simei,1,n-1) substr(kouho,i,1) substr(simei,n+1);
			print new;
		}
	} else {
		print "そのような文字は知りません";
	}
	print "";

	print "チューンの成果は";
	calc_all();

	return 0;
}