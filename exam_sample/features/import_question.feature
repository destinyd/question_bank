# language: zh-CN

功能: 实现批量导入题目的完整流程
  场景: 题目批量导入成功
    假如 题目录入员打算批量导入一系列题目
    * 按照批量导入题目标准格式示例文件编辑数据文件，编辑后的数据文件格式没有问题
    * 解析数据文件没有出错
    那么 题目导入成功

  场景: 题目批量导入失败
    假如 题目录入员打算批量导入一系列题目
    * 按照批量导入题目标准格式示例文件编辑数据文件，编辑后的数据文件格式有问题
    * 解析数据文件出现错误
    那么 题目导入失败，显示错误信息
