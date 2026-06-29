# Fabry-Perot 腔反射与透射系数 MATLAB App

本 App 根据 Eric D. Black, *An introduction to Pound-Drever-Hall laser
frequency stabilization* (2001) 的式 (3.1)，计算对称、无损 Fabry-Perot 腔的
复振幅反射系数与透射系数：

```text
F = r (exp(i phi) - 1) / (1 - r^2 exp(i phi))
T = (1-r^2) exp(i phi/2) / (1 - r^2 exp(i phi))
```

其中 `r` 是单镜振幅反射率，`phi = 2*pi*DeltaNu/FSR`。界面显示：

- 归一化反射强度 `|F|^2` 与反射相位 `arg(F)`
- 归一化透射强度 `|T|^2` 与透射相位 `arg(T)`
- 复平面上的反射、透射系数轨迹
- 无损腔能量守恒校验 `|F|^2 + |T|^2 = 1`
- 自由光谱范围、精细度和腔线宽
- 任意失谐点的数值读数和 CSV 数据导出

## 运行

在 MATLAB 中将当前目录切换到本文件夹，然后运行：

```matlab
launchPDHReflectionApp
```

也可以直接运行：

```matlab
app = PDHReflectionApp;
```

建议使用 MATLAB R2021a 或更新版本。精细度采用文献中的高精细度近似
`Finesse = pi/(1-r^2)`。精确共振时复反射系数为零，因此相位没有定义。

## 原生 macOS App

项目同时包含不依赖 MATLAB 的 SwiftUI 版本。已构建的 App 位于：

```text
dist/PDH Reflection.app
```

如需重新构建，在终端运行：

```bash
./macos/build_mac_app.sh
```

需要 macOS 13 或更高版本以及 Xcode Command Line Tools。当前构建目标为
Apple Silicon Mac。
