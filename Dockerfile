# 第一阶段：基于完整的 Go 镜像构建应用
# 使用官方 Go 镜像作为构建环境
FROM golang:latest AS builder

# 设置工作目录
WORKDIR /app

# 复制 go.mod 和 go.sum 文件
COPY go.mod ./
COPY go.sum ./

# 下载所有依赖
RUN go mod download

# 复制项目中的所有文件到工作目录
COPY . .

# 编译应用程序。这样可以创建一个更小体积的可执行文件
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gin-docker .

# 第二阶段：构建一个小镜像
# 使用 alpine 镜像，因为它的体积小，适合作为运行环境
FROM alpine:latest

# 在新的镜像中添加 ca-certificates，这是必须的如果你的应用需要与外部服务交互 (比如 HTTPS 请求)
RUN apk --no-cache add ca-certificates

# 从构建环境中拷贝编译完成的应用到当前目录
COPY --from=builder /app/gin-docker .

# 在容器启动时运行应用
ENTRYPOINT ["./gin-docker"]

# 暴露 8383 端口
EXPOSE 8383