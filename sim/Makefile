#==============================================================================
# 配置部分 - 用户可修改
#==============================================================================

# 项目基本信息
PROJECT_NAME    := bp_sim
VERSION_MAJOR   := 1
VERSION_MINOR   := 0
VERSION_PATCH   := 0
VERSION         := $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)

# 源文件目录
SRC_DIR         := src
# 头文件目录
INC_DIRS        := include

# 输出目录结构
BUILD_DIR       := build
BIN_DIR         := bin
OBJ_DIR         := obj

# 构建类型：debug 或 release（通过命令行参数覆盖）
ifndef BUILD_TYPE
    # 检查MAKECMDGOALS中是否包含gdb
    ifneq (,$(findstring gdb,$(MAKECMDGOALS)))
        BUILD_TYPE := debug
    else
        # 否则使用默认的release
        BUILD_TYPE := release
    endif
endif

# 编译器选择（根据平台自动选择）
ifeq ($(OS),Windows_NT)
    # Windows系统
    CC          := gcc
    CXX         := g++
    AR          := ar
    RM          := del /Q
    MKDIR       := mkdir
    RMDIR       := rmdir /S /Q
    EXE_EXT     := .exe
else
    # Unix-like系统
    CC          := gcc
    CXX         := g++
    AR          := ar
    RM          := rm -f
    MKDIR       := mkdir -p
    RMDIR       := rm -rf
    EXE_EXT     :=
endif

# 编译器警告选项
WARNINGS        := -Wall -Wextra \
        			-Wformat=2 \
        			-Wmissing-include-dirs \
        			-Wuninitialized \
        			-Wshadow \
        			-Wpointer-arith \
        			-Wcast-qual \
        			-Wsign-conversion \
    				-Wdouble-promotion \
					-Wno-narrowing	\
        			-Werror

# 公共编译选项
COMMON_CFLAGS   := $(addprefix -I,$(INC_DIRS)) \
                   -MMD -MP  # 自动生成依赖

# 调试版本选项
DEBUG_CFLAGS    := -g3 -O0 -DDEBUG -fsanitize=address,undefined
DEBUG_LDFLAGS   := -fsanitize=address,undefined

# 发布版本选项
RELEASE_CFLAGS  := -O3 -DNDEBUG -flto
RELEASE_LDFLAGS := -flto

CXXFLAGS		:= -std=c++20

# 根据构建类型选择选项
ifeq ($(BUILD_TYPE),debug)
    CFLAGS      := $(COMMON_CFLAGS) $(DEBUG_CFLAGS) $(WARNINGS)
    LDFLAGS     := $(DEBUG_LDFLAGS)
    BUILD_SUBDIR := debug
else
    CFLAGS      := $(COMMON_CFLAGS) $(RELEASE_CFLAGS) $(WARNINGS)
    LDFLAGS     := $(RELEASE_LDFLAGS)
    BUILD_SUBDIR := release
endif

# 最终输出路径
BUILD_OUT_DIR   := $(BUILD_DIR)/$(BUILD_SUBDIR)
BIN_OUT_DIR     := $(BIN_DIR)/$(BUILD_SUBDIR)
OBJ_OUT_DIR     := $(OBJ_DIR)/$(BUILD_SUBDIR)

# 自动查找源文件
# SRCS            := $(wildcard $(SRC_DIR)/*.c)
# SRCS            += $(wildcard $(SRC_DIR)/*.cc)
SRCS 			:= $(shell find src -name "*.c" -or -name "*.cc")
# 排除特定源文件（如果有的话）
EXCLUDE_SRCS    := #$(SRC_DIR)/ras.cc# 例如: $(SRC_DIR)/deprecated.c
SRCS            := $(filter-out $(EXCLUDE_SRCS),$(SRCS))

# 源文件扩展名列表
SRC_EXTS := .c .cc .cpp .cxx .C

# 生成 .o 文件列表（目标文件）
OBJS := $(foreach ext,$(SRC_EXTS),\
    $(patsubst $(SRC_DIR)/%$(ext),$(OBJ_OUT_DIR)/%.o,\
    $(filter %$(ext),$(SRCS))))

# 生成 .d 文件列表（依赖文件）
DEPS := $(foreach ext,$(SRC_EXTS),\
    $(patsubst $(SRC_DIR)/%$(ext),$(OBJ_OUT_DIR)/%.d,\
    $(filter %$(ext),$(SRCS))))

# 最终目标
TARGET          := $(BIN_OUT_DIR)/$(PROJECT_NAME)$(EXE_EXT)

CONFIG_JSON		?= config.json
TARGET_EXEC		:= $(TARGET) $(CONFIG_JSON)

#==============================================================================
# 构建规则
#==============================================================================

# 默认目标
.DEFAULT_GOAL := all

# 伪目标声明
.PHONY: all clean debug release 

# 主构建目标
all: $(TARGET)

run: release
	$(TARGET_EXEC)

gdb: debug
	gdb -s $(TARGET) --args $(TARGET_EXEC)

# 构建可执行文件
$(TARGET): $(OBJS)
	@echo "链接目标: $(TARGET)"
	@$(MKDIR) $(dir $@)
	$(CXX) $(OBJS) $(LDFLAGS) -o $@
	@echo "构建完成: $(TARGET)"

# 构建对象文件
$(OBJ_OUT_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "编译: $< -> $@"
	@$(MKDIR) $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_OUT_DIR)/%.o: $(SRC_DIR)/%.cc
	@echo "编译: $< -> $@"
	@$(MKDIR) $(dir $@)
	$(CXX) $(CFLAGS) $(CXXFLAGS) -c $< -o $@

# 包含自动生成的依赖
-include $(DEPS)

# 调试版本
debug:
	@$(MAKE) BUILD_TYPE=debug

# 发布版本
release:
	@$(MAKE) BUILD_TYPE=release

# 清理
clean:
	@echo "清理构建文件..."
	$(RMDIR) $(OBJ_DIR) $(BIN_DIR) $(BUILD_DIR)
	@echo "清理完成"

