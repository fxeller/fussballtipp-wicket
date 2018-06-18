package de.delmak.fussballtipp.persistence;

import java.util.Calendar;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Phase extends HibernateObject
{

	private Integer phaseId;

	public Integer getPhaseId()
	{
		return phaseId;
	}

	public void setPhaseId(Integer phaseId)
	{
		this.phaseId = phaseId;
	}

	private String phasename;

	public String getPhasename()
	{
		return phasename;
	}

	public void setPhasename(String phasename)
	{
		this.phasename = phasename;
	}

	private String description;

	public String getDescription()
	{
		return description;
	}

	public void setDescription(String description)
	{
		this.description = description;
	}

	private Date datefrom;

	public Date getDatefrom()
	{
		return datefrom;
	}

	public void setDatefrom(Date datefrom)
	{
		this.datefrom = datefrom;
	}

	private Boolean isgroupphase;

	public Boolean getIsgroupphase()
	{
		return isgroupphase;
	}

	public void setIsgroupphase(Boolean isgroupphase)
	{
		this.isgroupphase = isgroupphase;
	}

	private Set brackets = new HashSet();

	public Set getBrackets()
	{
		return brackets;
	}

	public void setBrackets(Set brackets)
	{
		this.brackets = brackets;
	}

	private Set matches = new HashSet();

	public Set getMatches()
	{
		return matches;
	}

	public void setMatches(Set matches)
	{
		this.matches = matches;
	}

	public Boolean getIsOpenForBets()
	{
		Calendar currentDateTime = Calendar.getInstance();
		Calendar closingDateTime = Calendar.getInstance();
		closingDateTime.setTime(getMinDatetimeByPhaseId(getPhaseId()));
		closingDateTime.add(Calendar.MINUTE, -150);
		
		return (currentDateTime.before(closingDateTime) == true);
	}

	@Override
	public String toString()
	{
		return String.format("%s_%s", getClass().getName(), getPhasename());
	}
	
	@Override
	public boolean equals(Object obj)
	{
		return obj.toString().equals(toString());				
	}

	@Override
	public int hashCode()
	{
		return toString().hashCode();
	}

	public static void insert(Phase object)
	{
		try
		{
			beginTransaction();
			getSession().save(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static void modify(Phase object)
	{
		try
		{
			beginTransaction();
			getSession().update(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static void delete(Phase object)
	{
		try
		{
			beginTransaction();
			getSession().delete(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static Phase getById(int id)
	{
		try
		{
			beginTransaction();
			
			Phase result = (Phase) getSession()
					.getNamedQuery("getPhaseById")
					.setInteger("id", id)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}

	public static Phase getByName(String name)
	{
		try
		{
			beginTransaction();
			
			Phase result = (Phase) getSession()
					.getNamedQuery("getPhaseByName")
					.setString("name", name)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static List getListAll()
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getPhasesAll")
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static Date getMinDatetimeByPhaseId(Integer phaseId)
	{
		try
		{
			beginTransaction();
			
			Date result = (Date) getSession()
					.getNamedQuery("getMinDatetimeByPhaseId")
					.setInteger("phaseId", phaseId)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
}
