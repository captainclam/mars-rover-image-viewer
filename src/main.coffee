rovers = require './enums/rovers.coffee'
cameras = require './enums/cameras.coffee'

favourites = require './favourites.coffee'

module.exports = [
  '$scope'
  'localStorageService'
  'photoService'
  ($scope, localStorageService, photoService) ->

    $scope.pane = 'results'

    $scope.manifests = {}

    $scope.filter = filter = localStorageService.get('filter') or
      date: null
      rover: rovers[0].label
      camera: cameras[0].code

    if $scope.filter.date
      $scope.filter.date = moment($scope.filter.date).toDate()

    $scope.enums =
      rovers: rovers
      cameras: cameras

    $scope.photos = []
    $scope.saved = localStorageService.get('saved') or []

    $scope.dateOptions = {}

    isSaved = (photo) ->
      existing = _.find $scope.saved, id: photo.id
      return existing?

    $scope.import = ->
      $scope.saved = favourites

    $scope.save = (photo) ->
      photo.saved = !photo.saved
      if isSaved photo
        $scope.saved = _.reject $scope.saved, id: photo.id
      else
        $scope.saved.push photo

      localStorageService.set 'saved', $scope.saved

    _updateManifest = (manifest) ->
      $scope.manifests[filter.rover] = manifest
      minDate = moment(manifest.landing_date).toDate()
      maxDate = moment(manifest.max_date).toDate()
      $scope.dateOptions = { minDate, maxDate }

      if $scope.filter.date is null or $scope.filter.date < minDate or $scope.filter.date > maxDate
        $scope.filter.date = moment(manifest.landing_date).toDate()

    $scope.updateManifest = ->
      if $scope.manifests[filter.rover]
        _updateManifest $scope.manifests[filter.rover]
      else
        photoService.getManifest filter.rover
        .then _updateManifest
        .catch (err) ->
          console.warn 'ERR', err

    $scope.search = ->
      localStorageService.set('filter', filter)
      $scope.error = null
      $scope.pane = 'results'
      $scope.photos = []
      $scope.loading = true
      photoService.getPhotos(filter)
      .then ({data}) ->
        unless data.photos
          throw new Error 'No Results'
        $scope.photos = data.photos
        $scope.photos?.map (photo) ->
          photo.saved = isSaved photo
          return photo
      .catch (error) ->
        $scope.error = error.message
      .finally ->
        $scope.loading = false

    # This method is used by the camera filter dropdown in accordance with
    #  the ng-options directive's `disable when <expression>` functionality
    # The camera.rovers and rover.flag values are used to form a bitmask.
    # Next rover to be added will require a flag value of 8, then 16, etc.
    # Any camera that exists on the new rover, will need to increment its
    #  rovers field by 8.
    $scope.hasCamera = (rover, camera) ->
      rover = _.find rovers, label: rover
      return (camera.rovers | rover.flag) is camera.rovers # bitmask

    $scope.updateManifest()
]