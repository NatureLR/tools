# .tmux.conf.local

- 添加了鼠标启动

```shell
set -g mouse on
```

- 添加了窗口同步快捷键

```shell
bind s setw synchronize-panes
```

- tmux 3.8 起 popup 默认使用内置灰色主题，改回跟随终端配色
set -g popup-style default
set -g popup-border-style default
