require "google/cloud/storage"

module GoogleCloudStorageUtil

  module_function

  def getBucket()
    storage = Google::Cloud::Storage.new(
      project_id: GoogleCloudStorageConstants::PROJECT_ID,
      credentials: GoogleCloudStorageConstants::CREDENTIAL_PATH
    )
    storage.bucket GoogleCloudStorageConstants::BUCKET
  end

  def deleteImageFile(fileName, inputBucket)
    if !fileName.nil?
      bucket = inputBucket.nil? ? getBucket() : inputBucket
      file = bucket.file(GoogleCloudStorageConstants::ICON_PATH + fileName)
      if !file.nil?
        file.delete
      end
    end
  end

  def updateImageFile(imageFile, userId, beforeFileName)
    fileName = generateImageFileName(userId, imageFile.content_type)
    if !imageFile.nil? && !fileName.nil?
      bucket = getBucket()
      if beforeFileName.nil?
        deleteImageFile(fileName, bucket)
      else
        deleteImageFile(beforeFileName, bucket)
      end
      addImageFile(imageFile, fileName, bucket)
      fileName
    else
      nil
    end
  end

  def getImageUrl(fileName, inputBucket)
    if !fileName.nil?
      bucket = inputBucket.nil? ? getBucket() : inputBucket
      file = bucket.file(GoogleCloudStorageConstants::ICON_PATH + fileName)
      if !file.nil?
        file.signed_url(method: "GET", expires: 60 * 60 * 24)
      else
        nil
      end
    else
      nil
    end
  end

  def addImageFile(imageFile, fileName, inputBucket)
    if !imageFile.nil? && !fileName.nil?
      bucket = inputBucket.nil? ? getBucket() : inputBucket
      # tempfileを送る
      file = bucket.create_file(imageFile.tempfile, GoogleCloudStorageConstants::ICON_PATH + fileName)
    else
      nil
    end
  end
 
  def generateImageFileName(userId, contentType)
    if contentType.index("image/") == 0
      ext = contentType.gsub!("image/", "")
      userId + "." + ext
    else
      nil
    end

  end

  private_class_method :generateImageFileName, :addImageFile

end
