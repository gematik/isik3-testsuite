@medikation
@mandatory
@Medication-Read-Extended
Feature: Lesen der Ressource Medication (@Medication-Read-Extended)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'medication-read-extended-id' hinterlegt sein.

      Legen Sie folgendes Medikament in Ihrem System an:
      Status: aktiv
      Arzneiform: Lösung zur Infusion
      Code (Textuell): Infusion bestehend aus 85mg Doxorubicin aufgeloest zur Verabreichung in 250ml 5-%iger (50 mg/ml) Glucose-Infusionsloesung
      Code: Doxorubicin
      Rezeptur (Wirkstofftyp): Wirkstoff allgemein
      Rezeptur (ATC-Code): L01DB01
      Rezeptur Stärke (Numerator): 85mg
      Rezeptur Stärke (Denominator): 250 Milliliter
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Medication"

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/Medication/${data.medication-read-extended-id}" with content type "xml"
    And resource has ID "${data.medication-read-extended-id}"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikament"
    And TGR current response with attribute "$..code.text.value" matches "Infusion bestehend aus 85mg Doxorubicin aufgeloest zur Verabreichung in 250ml 5-%iger (50 mg/ml) Glucose-Infusionsloesung"
    And TGR current response with attribute "$..Medication.status.value" matches "active"
    And FHIR current response body evaluates the FHIRPath "form.coding.where(system = 'http://standardterms.edqm.eu' and code = '11210000' and display = 'Solution for infusion').exists()" with error message 'Die Arzneiform entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "ingredient.where(isActive = 'true' and extension.where(url = 'https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/wirkstofftyp' and value.where(code = 'IN' and system = 'https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/CodeSystem/wirkstofftyp').exists()).exists() ).exists() and ingredient.where(item.coding.where(code = 'L01DB01' and system = 'http://fhir.de/CodeSystem/bfarm/atc' and display = 'Doxorubicin').exists() and strength.where(numerator.where(value ~ 85 and unit = 'mg' and system = 'http://unitsofmeasure.org' and code = 'mg').exists() and denominator.where(value ~ 250 and unit = 'Milliliter' and system = 'http://unitsofmeasure.org' and code = 'mL').exists()).exists() ).exists()" with error message 'Die Beschreibung der Rezeptur Doxorubicin entspricht nicht dem Erwartungswert'
