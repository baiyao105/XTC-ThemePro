该目录供 动态图标 使用:

1. 每一个文件夹,名称对应图标资源的 包名 或者 Activity名
   内部包含动态图标的资源:
	1.1 包名,格式为 "packageName.png";
	1.2 Activity 名称,格式为: "_ActivityName.png";
	
2. 如果是 lottie 动画图标,文件夹内容(参考目录 com.xtc.healthcheck):
	2.1 data.json 为 lottie 动画的 json, 命名必须为 "data.json"
	2.2 如果存在图片需要加载,将图片资源放入其中的 "images"目录