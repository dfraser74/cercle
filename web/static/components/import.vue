<template>
  <div class="panel panel-default">
    <div class="panel-heading">
      <h2 style="margin:0px;">Import data</h2>
    </div>
    <div class="panel-body">

      <el-steps :active="step" finish-status="success" simple style="margin-top: 20px">
        <el-step title="Step 1: Upload file" icon="el-icon-upload">></el-step>
        <el-step title="Step 2: Mapping" icon="el-icon-tickets"></el-step>
        <el-step title="Step 3: Preview and finish" icon="el-icon-view"></el-step>
      </el-steps>
      <!-- step-1 -->
      <div v-if="step === 0">
        <el-upload
          class="upload-import"
          drag
          ref="upload"
          width="100%"
          action="http://localhost:4000/company/5/import_data"
          :headers="headersUpload"
          accept=" .csv, .xlsx, .xls"
          :auto-upload="false"
          :on-preview="handlePreview"
          :on-remove="handleRemove"
          :on-success="handleUploaded"
          :file-list="fileList"
          :on-change="selectFile"
          multiple>
          <i class="el-icon-upload"></i>
          <div class="el-upload__text">
            Drop file here or <em>click to upload</em>
            <br />
            <br />
            <small>Only Excel (.xls and .xlsx) and .csv file types are supported.</small>
          </div>
        </el-upload>

        <div>
          <span class="pull-right">
            <el-button type="danger"  size="mini" @click="cancelImport">Cancel Import</el-button>
            <el-button type="success" size="mini"  @click="submitUpload" :disabled="disableNextStep">Next</el-button>
          </span>
        </div>
      </div>

      <!-- step-2 -->
      <div v-if="step === 1">
        <div class="mapping-info">
		      <h4>
            <i>
              Drag fields from the right side picker to the left side boxes matching your data.
              Unmapped columns will not be imported into Cercle.
            </i>
          </h4>
	      </div>
	      <div class="row mapping-sections">

          <div class="col-md-8" id="left-section">
			      <i class="fa fa-file fa-lg" aria-hidden="true"></i> &nbsp; File Fields
            <div class="table-responsive">
				      <table class="table table-bordered" id="left-section-table">
                  <tbody>
                  <tr v-for="item in mappingFields">
                    <td class="active csv-fields" >
                      <div class="csv-col">
                        <b>{{item.field}}</b>
                      </div>
                      <div class="csv-data">{{item.example}}</div>
                    </td>
                    <td :class="[{ 'contact-fields active': mappedField(item), 'info drop-fields': !mappedField(item) } ]">
                      <drop class="drop" @drop="handleDrop(item, ...arguments) " :class="{ allowed: dragging === item }">
                        <div v-if="!mappedField(item)">
                          Drag and drop field her!
                        </div>
                        <div v-if="mappedField(item)">
                          <i class="fa fa-building" v-if="item.mapping.type === 'organization'"></i>
                          <i class="fa fa-user" v-if="item.mapping.type === 'contact'"></i>
                          <span class="db-field">{{item.mapping.field}}</span>
                          <i class="el-icon-close"
                             @click="unMapField(item)"
                             style="float:right; margin-top:2px; cursor: pointer;"></i>
                        </div>
                      </drop>
                    </td>


                  </tr>

                </tbody>
				      </table>
			      </div>
		      </div>


          <div class="col-md-4" id="right-section">
            <el-tabs v-model="dbMappingField"  type="border-card">
              <el-tab-pane label="Contact Fields" name="contact_fields">
                <span slot="label">
                  <i class="fa fa-user fa-lg" aria-hidden="true"></i>
                  &nbsp; Contact Fields
                </span>

                <div>
					        <div class="table-responsive">
						        <table class="table table-bordered" id="contact-field-table">
                      <tbody>
                        <tr v-for='field in sortList(contactFields)'
                            :class="[{'required': requiredField('contact', field)}]">
                          <drag tag="td"
                                class="drag active contact-fields noselect"
                                :transferData="{ type: 'contact', field: field }">
                            <i class="fa fa-user" aria-hidden="true"></i><span class="db-field">{{field}}</span>
                          </drag>
                        </tr>
                      </tbody>
						        </table>
					        </div>
				        </div>
              </el-tab-pane>
              <el-tab-pane label="Organization Fields" name="organization_fields">
                <span slot="label">
                  <i class="fa fa-building fa-lg" aria-hidden="true"></i>
                  &nbsp; Organization Fields
                </span>
                <div class="table-responsive">
						      <table class="table table-bordered" id="organization-field-table">
							      <tbody>
                      <tr v-for='field in sortList(organizationFields)':class="[{'required': requiredField('organization', field)}]">
                        <drag
                          tag="td"
                          class="drag active organization-fields noselect"
                          :transferData="{ type: 'organization', field: field }">
                            <i class="fa fa-building" aria-hidden="true">
                            </i><span class="db-field">{{field}}</span>
                          </drag>
                      </tr>
                    </tbody>
						      </table>
					      </div>

              </el-tab-pane>

            </el-tabs>
		      </div>

	      </div>

        <div class="row" style="margin-top: 20px; padding-left: 17px; padding-right: 17px;">
          <span class="pull-left" style="margin-top:10px">
            <el-button type="primary"  size="mini" @click="back">Back</el-button>
          </span>
          <span class="pull-right" style="margin-top:10px">
            <el-button type="danger"  size="mini" @click="cancelImport">Cancel Import</el-button>
            <el-button type="success" size="mini"  @click="previewStep" :disabled="disableNextStep">Next</el-button>
          </span>
        </div>
      </div>

      <!-- step-3 -->
      <div v-if="step === 2">
        <div class="preview-info-section">
		      <h3>Preview Data</h3>
		      <p>Have a preview data according to the mapping done in <b>Step 2</b></p>
	      </div>

	      <div class="preview-section">
		      <div class="table-responsive">
			      <table class="table table-bordered" id="preview-data-table">
              <caption class="table-caption"><i class="fa fa-user" aria-hidden="true"></i><span>Contact</span></caption>
				      <thead >
                <tr class="tb-head">
                  <th v-for="h in previewHeaders">{{h}}</th>
                </tr>
              </thead>
				      <tbody>
                <tr>
                  <td v-for="h in previewValues">{{h}}</td>
                </tr>
              </tbody>
			      </table>
		      </div>

	      </div>

        <div>

          <span class="pull-left">
            <el-button type="primary"  size="mini" @click="back">Back</el-button>
          </span>
          <span class="pull-right">
            <el-button type="danger"  size="mini" @click="cancelImport">Cancel Import</el-button>
            <el-button type="success" size="mini"  @click="finishStep" :disabled="disableNextStep">Finish</el-button>
          </span>
        </div>
      </div>
    </div>
  </div>

</template>

<script>
  import { Drag, Drop } from 'vue-drag-drop';
  export default {
    props: ['companyId'],
    data() {
      return {
        dbMappingField: 'contact_fields',
        step: 0,
        fileList: [],
        disableUpload: true,
        headersUpload: { 'x-csrf-token': window.csrfToken },
        contactFields: [ ],
        organizationFields: [ ],
        mappingFields: [ ],
        fileId: null,
        previewHeaders: [],
        previewValues: []
      }
    },
    components: {
      'vue-draggable': VueDraggable,
      Drag, Drop
    },
    computed: {
      disableNextStep() {
        if (this.step === 0 ) {
          return this.disableUpload;
        };

        if (this.step === 1 ) {
          return !this.completedMapping();
        };

        if (this.step === 2 ) {
          return false;
        };
      }

    },
    methods: {
      requiredField(typeField, field) {
        if (typeField === 'contact' && this.$_.includes(['full_name', 'first_name', 'last_name'], field)){
          return true;
        }

        if (typeField === 'organization' && this.$_.includes(['name'], field)){
          return true;
        }
      },
      back() {
        if (this.step === 2 ) {
          this.step = 1
        } else if (this.step === 1 ) {
          this.disableUpload = true;
          this.step = 0
        };
      },

      finishStep() {
        let url = "/company/" + this.companyId + "/create_nested_data";
        let mappedData = { contact: {}, organization: {} };

        let completedFields = this.$_.filter(this.mappingFields, (v) => { return !this.$_.isEmpty(v.mapping) });
        this.$_.forEach(completedFields, (item) => {
          mappedData[item.mapping.type][item.mapping.field] = item.field;
        })

        this.$http.post(
          url,
          { mapping: mappedData, tempFile: this.fileId },
          {headers: {'x-csrf-token': window.csrfToken}}
        ).then( (resp) => {
          this.$message(resp.message);
          window.location = '/company/'+this.companyId+'/contact';
        }, (error) => {
          this.$message.error('Some error occured, Please try again.');
        })
      },
      previewStep() {
        let url = "/company/" + this.companyId + "/view_uploaded_data";
        let mappedData = { contact: {}, organization: {} };

        let completedFields = this.$_.filter(this.mappingFields, (v) => { return !this.$_.isEmpty(v.mapping) });
        this.$_.forEach(completedFields, (item) => {
          mappedData[item.mapping.type][item.mapping.field] = item.field;
        })

        this.$http.post(
          url,
          { mapping: mappedData, tempFile: this.fileId },
          {headers: {'x-csrf-token': window.csrfToken}}
        ).then( (resp) => {
          window.w = resp;
          this.previewValues = resp.data.contact_values.concat(resp.data.organization_values)
          this.previewHeaders = resp.data.contact_headers.concat(resp.data.organization_headers)
          this.step = 2;
        })
      },
      completedMapping() {
        let completedFields = this.$_.map(
          this.$_.filter(this.mappingFields, (v) => { return !this.$_.isEmpty(v.mapping) }),
          (n) => { return  n.mapping.type + '_' + n.mapping.field }
        );
        let mappedContactName = this.$_.includes(completedFields, 'contact_full_name') || (
          this.$_.includes(completedFields, 'contact_first_name') &&
            this.$_.includes(completedFields, 'contact_last_name')
        );
        let mappedOrganizationName = this.$_.includes(completedFields, 'organization_name');
        return mappedContactName && mappedOrganizationName;

      },
      sortList(list) {
         return this.$_.orderBy(list)
      },
      unMapField(item) {
        if (item.mapping.type === 'contact') {
          this.contactFields.push(item.mapping.field);
        }
        if (item.mapping.type === 'organization') {
          this.organizationFields.push(item.mapping.field);
        }
        item.mapping = {}
      },
      mappedField(item) {
        return !this.$_.isEmpty(item.mapping);
      },
      handleDrop(item, data) {
        window.w = this
        if (data.type === 'contact') {
          this.contactFields.splice(this.contactFields.indexOf(data.field), 1);
          if (!this.$_.isEmpty(item.mapping)) {
            this.contactFields.push(item.mapping.field);
          }
          item.mapping = { type: 'contact', field: data.field }
        }

        if (data.type === 'organization') {
          this.organizationFields.splice(this.organizationFields.indexOf(data.field), 1);
          if (!this.$_.isEmpty(item.mapping)) {
            this.organizationFields.push(item.mapping.field);
          }
          item.mapping = { type: 'organization', field: data.field }
        }
      },
      handleUploaded(resp, file, fileList) {
        this.contactFields = resp.contact_fields;
        this.organizationFields = resp.organization_fields;
        this.mappingFields = this.$_.map(
          this.$_.zip(resp.headers, resp.first_row), (h) => {
            return { field: h[0], example: h[1],  mapping: {  } }
          });
        this.fileId = resp.temp_file;
        this.step = 1

      },
      cancelImport() {
        window.location.href = '/company/' + this.companyId + '/contact'
      },
      handleRemove(_, files){
        this.disableUpload = true;
      },
      selectFile(file, files) {
        this.$refs.upload.clearFiles()
        this.$refs.upload.uploadFiles = [file]
        this.disableUpload = false;
      },
      submitUpload() {
        this.$refs.upload.submit();
      }
    },
    mounted() {

    }
  };
</script>

<style lang="sass">
  .noselect {
  -webkit-touch-callout: none; /* iOS Safari */
    -webkit-user-select: none; /* Safari */
     -khtml-user-select: none; /* Konqueror HTML */
       -moz-user-select: none; /* Firefox */
        -ms-user-select: none; /* Internet Explorer/Edge */
            user-select: none; /* Non-prefixed version, currently
                                  supported by Chrome and Opera */
                                    }

tr.required td {
  border-color: red !important;
  }
.drop.allowed {
		background-color: #dfd;
	}
  .upload-import {
    .el-upload {
      width: 100%;
      }
        .el-upload__input {
          display: none !important;
          }
            .el-upload-dragger {
              width: 100%;
              }
                }
</style>
