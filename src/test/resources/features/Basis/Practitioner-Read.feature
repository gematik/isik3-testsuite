@basis
@mandatory
@Practitioner-Read
Feature: Lesen der Ressource Practitioner (@Practitioner-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'practitioner-read-id' hinterlegt sein.

      Testdatensatz (Name: Wert)
      Legen Sie folgende Arztstammdaten in Ihrem System an:
      Vorname: Walter
      Nachname: Musterarzt
      Geschlecht: männlich
      Lebenslange Arztnummer (falls vom System unterstützt): 123456789
      Einheitliche Fortbildungsnummer (falls vom System unterstützt): 123456789123456
      Telematik-ID: 123456789
      Adresse: Musterweg 13 11111 Berlin
      Adresse (Stadtteil): Wilmersdorf
      Geschlecht: Männlich
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Practitioner"

  Scenario: Read einer Practitioner-Ressource anhand der ID
    Then Get FHIR resource at "http://fhirserver/Practitioner/${data.practitioner-read-id}" with content type "xml"
    And resource has ID "${data.practitioner-read-id}"
    And FHIR current response body is a valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPersonImGesundheitsberuf"
    And TGR current response with attribute "$..gender.value" matches "male"
    And FHIR current response body evaluates the FHIRPath "name.where(use='official').given.matches('Walter')"
    And FHIR current response body evaluates the FHIRPath "name.where(use='official').family.matches('Musterarzt')"
    And FHIR current response body evaluates the FHIRPath "identifier.where(system='https://fhir.kbv.de/NamingSystem/KBV_NS_Base_ANR').exists().not() or (identifier.where(system='https://fhir.kbv.de/NamingSystem/KBV_NS_Base_ANR').exists() and identifier.where(system='https://fhir.kbv.de/NamingSystem/KBV_NS_Base_ANR').value = '123456789')" with error message 'Die vorgefundene LANR-Nummer entspricht nicht der Vorgabe'
    And FHIR current response body evaluates the FHIRPath "identifier.where(system='http://fhir.de/sid/bundesaerztekammer/efn').exists().not() or (identifier.where(system='http://fhir.de/sid/bundesaerztekammer/efn').exists() and identifier.where(system='http://fhir.de/sid/bundesaerztekammer/efn').value = '123456789123456')" with error message 'Die vorgefundene einheitliche Fortbildungsnummer entspricht nicht der Vorgabe'
    And FHIR current response body evaluates the FHIRPath "identifier.where(system='https://gematik.de/fhir/sid/telematik-id' and value = '123456789').exists()" with error message 'Die Telematik-ID entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "address.where(type = 'both' and city = 'Berlin' and postalCode = '11111' and country = 'DE' and line = 'Musterweg 13' and line.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName' and value = 'Musterweg').exists() and line.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber' and value = '13').exists()).exists()" with error message 'Die Adresse entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "address.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-precinct' and (value as string) = 'Wilmersdorf').exists()" with error message 'Stadtteil ist falsch angegeben'
