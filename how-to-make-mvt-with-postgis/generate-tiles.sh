#!/bin/bash

set -e

x0=16597
y0=11273
zoom=15

function admin() {
  tz=$1
  tx=$2
  ty=$3
  echo "
  COPY (
    SELECT encode(ST_AsMVT(q, 'admin', 4096, 'geom'), 'hex')
    FROM (
      SELECT id, name, admin_level,
        ST_AsMvtGeom(
          geometry,
          BBox($tx, $ty, $tz),
          4096,
          256,
          true
        ) AS geom
      FROM import.osm_admin
      WHERE geometry && BBox($tx, $ty, $tz)
      AND ST_Intersects(geometry, BBox($tx, $ty, $tz))
    ) AS q
  ) TO STDOUT;
  "
}

function buildings() {
  tz=$1
  tx=$2
  ty=$3
  echo "
  COPY (
    SELECT encode(ST_AsMVT(q, 'buildings', 4096, 'geom'), 'hex')
    FROM (
      SELECT id, name, type,
        ST_AsMvtGeom(
          geometry,
          BBox($tx, $ty, $tz),
          4096,
          256,
          true
        ) AS geom
      FROM import.osm_buildings
      WHERE geometry && BBox($tx, $ty, $tz)
      AND ST_Intersects(geometry, BBox($tx, $ty, $tz))
    ) AS q
  ) TO STDOUT;
  "
}

function amenities() {
  tz=$1
  tx=$2
  ty=$3
  echo "
  COPY (
    SELECT encode(ST_AsMVT(q, 'amenities', 4096, 'geom'), 'hex')
    FROM (
      SELECT id, name, type,
        ST_AsMvtGeom(
          geometry,
          BBox($tx, $ty, $tz),
          4096,
          256,
          true
        ) AS geom
      FROM import.osm_amenities
      WHERE geometry && BBox($tx, $ty, $tz)
      AND ST_Intersects(geometry, BBox($tx, $ty, $tz))
    ) AS q
  ) TO STDOUT;
  "
}

offset=1

for (( z=$zoom; z<=16; ++z )); do
  for (( x=$x0-$offset; x<=$x0+$offset; ++x )); do
    mkdir -p ./tiles/$z/$x
    for (( y=$y0-$offset; y<=$y0+$offset; ++y )); do
      file="./tiles/$z/$x/$y.pbf"
      {
      docker exec postgis psql gis gis -tq -c "$(admin $z $x $y)" | xxd -r -p ;
      docker exec postgis psql gis gis -tq -c "$(buildings $z $x $y)" | xxd -r -p ;
      docker exec postgis psql gis gis -tq -c "$(amenities $z $x $y)" | xxd -r -p ;
      } > $file
      du -h $file
    done
  done
  let "offset *= 2"
  let "x0 = x0 * 2"
  let "y0 = y0 * 2"
done
