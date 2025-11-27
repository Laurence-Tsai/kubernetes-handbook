#!/bin/bash
# macOS & Linux 兼容的 Hugo shortcode 修复脚本

echo "🔧 开始修复 Hugo shortcodes..."

# 检查系统类型
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_INPLACE="sed -i ''"
    echo "✅ 检测到 macOS，使用 macOS sed 语法"
else
    SED_INPLACE="sed -i"
    echo "✅ 检测到 Linux，使用 Linux sed 语法"
fi

# 查找所有 .md 文件
find . -name "*.md" -type f | while read -r file; do
    echo "📝 正在修复: $file"
    
    # 备份原文件
    cp "$file" "$file.backup"
    
    # 修复 table 开头标签：{{< table title="xxx" >}} → ## xxx
    $SED_INPLACE 's/{{< table title="\(.*\)" >}}/## \1/g' "$file"
    
    # 移除 table 结束标签：{{< /table >}}
    $SED_INPLACE 's/{{< \/table >}}//g' "$file"
    
    # 修复其他可能的 Hugo shortcodes
    $SED_INPLACE 's/{{< highlight \([^>]*\) >}}/``` \1/g' "$file"
    $SED_INPLACE 's/{{< \/highlight >}}/```/g' "$file"
    
    # 修复 model 变量错误
    $SED_INPLACE 's/{{\(model\|variable\)=\([^}]*\)}}/{{\1: \2}}/g' "$file"
    
    # 清理多余的空行
    $SED_INPLACE '/^$/{
        N
        /^\n$/D
    }' "$file"
    
    echo "✅ $file 修复完成"
done

echo "🎉 所有文件修复完成！"

# 显示修改统计
echo "📊 修改统计："
find . -name "*.md" -exec grep -l "table title" {} \; | wc -l