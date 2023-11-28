@basis
@dokumentenaustausch
@terminplanung
@vitalparameter
@optional
@Patient-Search-Optional
Feature: Testen von KANN-Suchparametern gegen patient-read (@Patient-Search-Optional)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Patient-Read muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "xml"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Patient" and interaction.where(code = "search-type").exists()).exists()
    """

  Scenario Outline: Validierung des CapabilityStatements von <searchParamValue>
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Patient" and searchParam.where(name = "<searchParamValue>" and type = "<searchParamType>").exists()).exists()
    """

    Examples:
      | searchParamValue   | searchParamType |
      | name               | string          |
      | _profile           | uri             |
      | address            | string          |
      | address-city       | string          |
      | address-country    | string          |
      | address-postalcode | string          |
      | active             | token           |
      | telecom            | token           |

  Scenario: Suche nach Patient*innen anhand des Namens
    Then Get FHIR resource at "http://fhirserver/Patient/?name=Graf" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(name.where(family.toString().matches('Graf|Gräfin') or given.where(value.toString().matches('Graf|Gräfin'))).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Patient" is valid ISIK3 and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPatient"

  Scenario: Suche nach Patient*innen anhand der Adresse (Stadt)
    Then Get FHIR resource at "http://fhirserver/Patient/?address-city=Musterdorf" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(address.where(city = 'Musterdorf').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Patient*innen anhand der Adresse (Land)
    Then Get FHIR resource at "http://fhirserver/Patient/?address-country=CH" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(address.where(country = 'CH').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Patient*innen anhand der Adresse (Postleitzahl)
    Then Get FHIR resource at "http://fhirserver/Patient/?address-postalcode=9876" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(address.where(postalCode.contains('9876')).exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Patient*innen anhand des Status
    Then Get FHIR resource at "http://fhirserver/Patient/?gender=male" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(active=true)" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach Patient*innen anhand der Telefonnummer
    Then Get FHIR resource at "http://fhirserver/Patient/?telecom=201-867-5309" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all((telecom = '201-867-5309').exists())" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'

  Scenario: Suche nach PatientInnen anhand des Profils
    Then Get FHIR resource at "http://fhirserver/Patient/?_profile=https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPatient" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath "entry.resource.all(meta.profile = 'https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPatient')" with error message 'Es gibt Suchergebnisse, die nicht dem Kriterium entsprechen'
