<template>
  <el-card shadow="never">
    <div class="action-bar">
      <h2>Đơn vị tính</h2>
      <el-button type="primary" :icon="Plus" @click="handleAdd">Tạo đơn vị</el-button>
    </div>
    <el-table :data="unitData" stripe style="width: 100%">
      <el-table-column prop="name" label="Tên đơn vị" />
      <el-table-column prop="code" label="Mã" />
      <el-table-column prop="symbol" label="Ký hiệu" />
      <el-table-column label="Hành động" width="180">
        <template #default="scope">
          <el-button size="small" @click="handleEdit(scope.row)">Sửa</el-button>
          <el-button size="small" type="danger" @click="handleDelete(scope.row.id)">Xóa</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>

  <!-- Unit Dialog -->
  <el-dialog v-model="dialogVisible" :title="isEdit ? 'Sửa đơn vị' : 'Tạo đơn vị'" width="600px">
    <el-form :model="form" label-width="120px">
      <el-form-item label="Tên đơn vị">
        <el-input v-model="form.name" />
      </el-form-item>
      <el-form-item label="Mã">
        <el-input v-model="form.code" />
      </el-form-item>
      <el-form-item label="Ký hiệu">
        <el-input v-model="form.symbol" />
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
  symbol: '',
})

const unitData = ref([
  { id: 1, name: 'Cái', code: 'PCS', symbol: 'cái' },
  { id: 2, name: 'Kilogram', code: 'KG', symbol: 'kg' },
  { id: 3, name: 'Thùng', code: 'BOX', symbol: 'thùng' },
])

const resetForm = () => {
  form.id = 0
  form.name = ''
  form.code = ''
  form.symbol = ''
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
  ElMessageBox.confirm('Bạn có chắc chắn muốn xóa đơn vị này không?', 'Cảnh báo', {
    confirmButtonText: 'Xóa',
    cancelButtonText: 'Hủy',
    type: 'warning',
  }).then(() => {
    unitData.value = unitData.value.filter(item => item.id !== id)
    ElMessage({ type: 'success', message: 'Xóa thành công' })
  })
}

const handleSubmit = () => {
  if (isEdit.value) {
    const index = unitData.value.findIndex(item => item.id === form.id)
    if (index !== -1) {
      unitData.value[index] = { ...form }
    }
  } else {
    form.id = Date.now()
    unitData.value.unshift({ ...form })
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
