BEGIN {
  sw = 40;		# 元のパターンの幅
  dw = 78;		# 生成される RCS の幅
  hdw = dw / 2;
  w = 20;		# 両目の幅
  h = 1;		# 画面と基準面の距離 (目と画面の距離が単位)
  d = .2;		# 単位当たりの浮き上がり方 (〃)
  ss = "abcdefghijklmnopqrstuvwxyz0123456789!#$%^&*()-=\\[];'`,./";
  srand();
}
{
  xr = -hdw; y = h * 1.0; maxxl = -999;
  s = "";
  while (xr < hdw) {
    x = xr * (1 + y) - y * w / 2;
	i = x / (1 + h) + sw / 2 + 1;
	c = i < 1 ? 0 : substr($0, i, 1);
	y = h - d * c;
	xl = xr - w * y / (1 + y);
	if (xl < -hdw || xl >= hdw || xl <= maxxl) {
		c = substr(ss, rand() * length(ss) + 1, 1); 
	} else {
		c = substr(s, xl + hdw + 1, 1);
		maxxl = xl;
	}
    s = s c;
    xr++;
  }
  print s;
}
