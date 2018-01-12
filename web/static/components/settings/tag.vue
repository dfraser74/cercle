<template>
  <div class="box box-primary">
    <div class="box-body">
          <div class="row">
            <div class="col-md-12">
              <h4>Tags</h4>

              <el-table
            :show-header="false"
            :data="tags"
            style="width: 100%">
            <el-table-column prop="name" label="" >
              <template slot-scope="scope">
                <el-input size="small" v-on:input="$set(scope.row, 'changed', true)"
                          v-model="scope.row.name" style="max-width:80%;">

                </el-input>
                <el-button @click="updateTag(scope.row)"
                           size="small" type="success" v-if="scope.row.changed">
                    Save
                  </el-button>
              </template>
            </el-table-column>
            <el-table-column width="100">
              <template slot-scope="scope">
                <el-button @click="deleteTag(scope.row)" size="mini" type="danger">
                  Delete
                </el-button>
              </template>
            </el-table-column>
            </el-table>
            </div>
          </div>
        </div>
  </div>
</template>
<script>
  export default {
    props: ['companyId'],
    data() {
      return {
  tags: []
      };
    },
  methods: {
    updateTag(tag) {
      let url = '/api/v2/company/' + this.companyId + '/tag/' + tag.id;
      this.$http.put(url, {tag: {name: tag.name }}).then(resp => {
        tag.changed = false;
      })
    },
    deleteTag(tag) {
      let url = '/api/v2/company/' + this.companyId + '/tag/' + tag.id;
      this.$http.delete(url).then(resp => {
        let tagIndex = this.tags.findIndex((u)=> { return u.id === tag.id; })
        this.tags.splice(tagIndex, 1);
      })
    },
    fetchTags() {
      let url = '/api/v2/company/' + this.companyId + '/tag';
      this.$http.get(url).then(resp => {
        this.tags = resp.data.data
      });
    }
  },
  computed: { },
  mounted() {
    this.fetchTags();
  }
};
</script>
<style lang="sass" scoped>
  textarea {
    width: 100%;
    height: 100px;
    word-wrap: break-word;
  }

</style>
