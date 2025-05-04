BEGIN {
	_asc_init();
	nf = 0;
	split("+ + + + + +", right_char);
	split("+ + + + + +", left_char);
	split("+ + + + + +", x_char);
	split("- = - = - =", hline_char);
	split("| |", vline_char); 
	width = 1;
	for (i = 1; i < ARGC && ARGV[i] ~ /^-/; i++) {
		if (ARGV[i] == "-a") { #dummy
		} else if (ARGV[i] == "-j") {
			split("┏ ┏ ┠ ┣ ┗ ┗", left_char);
			split("┓ ┓ ┨ ┫ ┛ ┛", right_char);
			split("┬ ┯ ┼ ┿ ┴ ┷", x_char);
			split("─ ━ ─ ━ ─ ━", hline_char);
			split("│ ┃", vline_char); 
			width = 1;   # 全角幅の罫線の場合 2
		} else {			
			usage();
			exit(-1);
		}
		delete ARGV[i] ;
	}
}

{
	buffer[n++] = $0;
	for (i = 1; i <= NF; i++) {
		len = blength($i);
		if ($i ~ /^\(.*\)$/) {
			len -= 2;
		}
		if (col[i] < len) {
			col[i] = len;
		}
	}
	nf = (nf < NF) ? NF : nf;
}

END {
	if (escape) exit escape;

	for (i = 1; i <= nf; i++) {
		col[i] += col[i] % width;
	}
	for (i = 1; i <= nf; i++) {
		left_fmt[i] = sprintf("%%-%ds", col[i]);
		right_fmt[i] = sprintf("%%%ds", col[i]);
	}

	for (i = 0; i < n && buffer[i] == ""; i++);
	if (i == n) exit;

	hs = 2;
	while (i < n) {
		hline(hs);

		split(buffer[i], field);
		for (j = 1; j <= nf; j++) {
			vline((j == 1) + 1);
			if (field[j] ~ /^\(.*\)$/) {
				field[j] = substr(field[j], 2, length(field[j]) - 2);
				printf "%s", center(col[j], field[j]);
			} else if (field[j] ~ /^[\\$¥]?-?[0-9,.]+円?錠?$/) {
				# 全角文字補正 nzen(str) str中の全角文字の数
		        right_fmt_zen = sprintf("%%%ds", col[j] - nzen(field[j]));
				printf right_fmt_zen, field[j];
			} else {
				# 全角文字補正 nzen(str) str中の全角文字の数
		        left_fmt_zen = sprintf("%%-%ds", col[j] - nzen(field[j]));
				printf left_fmt_zen, field[j];
			}
		}
		vline(2);
		printf "\n";

		hs = 3; i++;
		while (i < n && buffer[i] == "") {
			hs = 4; i++;
		}
	}
	hline(6);
}

function hline(kind		,i, j) {
	for (i = 1; i <= nf; i++) {
		printf "%s", (i == 1) ? left_char[kind] : x_char[kind];
		for (j = 1; j <= col[i] / width; j++) {
			printf "%s", hline_char[kind];
		}
	}
	printf "%s\n", right_char[kind];
}

function vline(kind) {
	printf "%s", vline_char[kind];
}

function center(width, item,		ilen, llen)
{
	ilen = blength(item);
	if (ilen > width) { # unreachable
		return substr(item, width);
	}
	llen = int((width - ilen) / 2);
	return repeat(" ", llen) item repeat(" ", width - ilen - llen);
}

function repeat(s, n,		r)
{
	r = "";
	while (n-- > 0) {
		r = r s;
	}
	return r;
}

function usage() {
	printf "usage: %s -f hyou.awk [-- -ajn] <filename>\n", 
	 ARGV[0] > "/dev/stderr";
	escape = 1; exit;
}

# https://mfi.sub.jp/_html_awk/gawk_blength.html
#  _asc_init();ASCII+半角カナ辞書(Shift_JIS)
function _asc_init(    i, hk, ar, qt) {
    for (i = 0; i < 128; i++) _asc[sprintf("%c", i)] = i;
    hk = "｡｢｣､･ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝﾞﾟ";
    qt = split(hk, ar, "");
    for (i = 1; i <= qt; i++) _asc[ar[i]] = 160 + i;    #Shift_JIS
    _SCLP = " ";     #マルチバイト文字の断片を表す文字
}
#  blength();文字列長さ疑似バイトを返す(辞書_asc)
function blength(str,    i, ch, lenb) {
    lenb = 0;
    while (ch = substr(str, ++i, 1))
        (ch in _asc) ? lenb += 1 : lenb += 2;
    return lenb;
}

#  nzen();全角文字数を返す
function nzen(str,    i, ch, lenb) {
    lenb = 0;
    while (ch = substr(str, ++i, 1))
        if (!(ch in _asc)) lenb++;
    return lenb;
}