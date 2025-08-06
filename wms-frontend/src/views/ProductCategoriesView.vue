<template>
  <el-card shadow="never">
    <div class="action-bar">
      <h2>Danh mục sản phẩm</h2>
      <el-button type="primary" :icon="Plus" @click="handleAdd">Tạo danh mục</el-button>
    </div>
    <el-table :data="categoryData" stripe row-key="id" style="width: 100%">
      <el-table-column prop="name" label="Tên danh mục" />
      <el-table-column prop="code" label="Mã danh mục" />
      <el-table-column prop="description" label="Mô tả" />
      <el-table-column label="Hành động" width="180">
        <template #default="scope">
          <el-button size="small" @click="handleEdit(scope.row)">Sửa</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row.id)">Xóa</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>

  <!-- Category Dialog -->
  <el-dialog v-model="dialogVisible" :title="isEdit ? 'Sửa danh mục' : 'Tạo danh mục'" width="600px">
    <el-form :model="form" label-width="120px">
      <el-form-item label="Tên danh mục">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="Mã danh mục">
        <el-input v-model="form.code" />
      </el-form-item>
      <el-form-item label="Mô tả">
        <el-input v-model="form.description" type="textarea" />
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="dialogVisible = false">Hủy</el-button>
        <el-button type="primary" @click="handleSubmit">
          {{ isEdit ? 'Cập nhật' : 'Tạo mới' }}
        </el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const dialogVisible = ref(false)
const isEdit = ref(false)

const form = reactive({
  id: 0,
  name: '',
  code: '',
  description: '',
})

const categoryData = ref([
  { id: 1, name: 'Điện tử', code: 'DT', description: 'Các thiết bị điện tử' },
  { id: 2, name: 'Hàng tiêu dùng', code: 'HTD', description: 'Hàng tiêu dùng nhanh' },
])

const resetForm = () => {
  form.id = 0
  form.name = ''
  form.code = ''
  form.description = ''
}

const handleAdd = () => {
  isEdit.value = false
  resetForm()
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  isEdit.value = true
  Object.assign(form, row)
  dialogVisible.value = true
}

const handleDelete = (id: number) => {
  ElMessageBox.confirm('Bạn có chắc chắn muốn xóa danh mục này không?', 'Cảnh báo', {
    confirmButtonText: 'Xóa',
    cancelButtonText: 'Hủy',
    type: 'warning',
  }).then(() => {
    categoryData.value = categoryData.value.filter(item => item.id !== id)
    ElMessage({ type: 'success', message: 'Xóa thành công' })
  })
}

const handleSubmit = () => {
  if (isEdit.value) {
    const index = categoryData.value.findIndex(item => item.id === form.id)
    if (index !== -1) {
      categoryData.value[index] = { ...form }
    }
  } else {
    form.id = Date.now()
    categoryData.value.unshift({ ...form })
  }
  dialogVisible.value = false
  ElMessage({ type: 'success', message: isEdit.value ? 'Cập nhật thành công' : 'Tạo mới thành công' })
}
</script>

<style scoped>
.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.action-bar h2 {
  font-size: 20px;
  margin: 0;
  color: #303133;
}
</style>
