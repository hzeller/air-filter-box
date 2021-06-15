# Air filter box
for the next wildfire season.

This is using [MERV13 filters from Amazon](https://amazon.com/dp/B00CJZ7TB2)

### Generate file

The cut is dependent on the thickness of the used plywood. To generate DXF
file, [OpenSCAD] needs to be installed. Then, measure the
actual thickness of the plywood.

Let's assume it is **5.7mm**. Then this command will generate the necessary
DXF file:

```
make air-filter-cuts-5.7mm.dxf
```

### Laser cut

Everything is in one big DXF file of which probably parts have to be disabled
to cut one at a time on a normal-sized laser cutter :)

To laser-cut, it is probably good to use an inward kerf correction for the
finger slots.

![](img/cuts-sample.png)

### Assembly

Glue in top and bottom filter stopper (shown in blue below first).

Corner parts have to be slotted together length-wise, then the bottom and
top finger joints fit exactly with the corresponding top and bottom plate.

Corner parts can be glued, but for now suggestion only to glue on the bottom
side, so that we can remove the top-part easily (will be needed for second
version fan mount).

Note, the center cross at the bottom and diagonal slots at the top-plate
corners are not yet used (will be for the fan mount later)

![](img/assembly-draw.gif)

[OpenScad]: https://openscad.org/downloads.html