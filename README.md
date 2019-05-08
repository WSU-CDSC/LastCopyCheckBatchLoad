# LastCopyCheckBatchLoad

Libraries frequently need to check to see if their item is the last copy within a consortium. This code uses Ex Libris APIs to check PNX records to see how many institutions own a certain item. The code is currently written in PowerShell.

Steps taken:
	Start with a list of Barcodes
	Use the Item Barcode API to fetch MMS IDs
	Use the Primo Search API to fetch Title, Alma ID, and Alma ID Count
