#!/usr/bin/env python

import argparse
import pathlib
import os
from PyPDF2 import PdfFileMerger, PdfFileReader


parser = argparse.ArgumentParser(description='Combine PDFs by electrode')
parser.add_argument('-s', '--subject-code', type=str)
parser.add_argument('-t', '--fig-type', type=str, default='timeseries')
parser.add_argument('-d', '--fig-dir', type=pathlib.Path, default=pathlib.Path("./figures"))
args = parser.parse_args()

subject_dir = args.fig_dir / args.fig_type / args.subject_code

merger_outter = PdfFileMerger()
for p in subject_dir.iterdir():
    merger = PdfFileMerger()
    if p.is_dir():
        pdf_files = [f for f in os.listdir(p) if f.endswith('.pdf')]
        pdf_files.sort

        for filename in pdf_files:
            filepath = p / filename
            with open(filepath, 'rb') as f:
                merger.append(PdfFileReader(f))

        outpath = args.fig_dir / args.fig_type / args.subject_code / "sub-{subcode:s}_elec-{elec:s}_label-{type:s}.pdf".format(subcode=args.subject_code, elec=p.name, type=args.fig_type)
        merger.write(outpath)

        with open(outpath, 'rb') as f:
            merger_outter.append(PdfFileReader(f))

outpath = args.fig_dir / args.fig_type / "sub-{subcode:s}_label-{type:s}.pdf".format(subcode=args.subject_code, type=args.fig_type)
merger_outter.write(outpath)