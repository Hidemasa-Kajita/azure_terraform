# azure terraform

## Make Command
環境変数`${env}`は`dev`, `stg`, `prod`の中から選択可能です。
※ 現状devのみ使用可能

- 使用するディレクトリの準備
```
make init env=${env}
```

- 実行計画の作成
```
make plan env=${env}
```

- 構成の適用
```
make apply env=${env}
```

- 構成の破壊
```
make destroy env=${env}
```